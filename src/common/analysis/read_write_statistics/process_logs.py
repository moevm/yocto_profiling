import re
from collections import defaultdict
from statistics import median
import argparse


def parse_arguments():
    parser = argparse.ArgumentParser(description='Process log file for statistics.')
    parser.add_argument("-l", "--log_file", type=str, help='Path to the log file')
    parser.add_argument("-t", "--tasks_file", type=str, help='Path to the tasks pid info file')
    return parser.parse_args()


def calculate_median(data):
    if not data:
        return 0
    return median(data)


def write_statistics(output_file, task_info, stats, is_rwv=False):
    with open(output_file, 'w') as f:
        if is_rwv:
            f.write(f"{'PID':>6} {'Task':>30} {'Package':>40} {'Readv Calls':>12} {'Total Readv':>12} "
                    f"{'Max Readv':>16} {'Median Readv':>16} "
                    f"{'Writev Calls':>12} {'Total Writev':>12} {'Max Writev':>16} {'Median Writev':>16}\n")
            f.write("=" * 200 + "\n")
            for pid, stat in stats.items():
                task_name, package_name = task_info.get(pid, ('bitbake_process', ''))
                f.write(
                    f"{pid:>6} {task_name:>30} {package_name:>40} {stat['readv_calls']:>12} "
                    f"{stat['total_readv_bytes']:>12} {stat['max_readv_bytes']:>16} "
                    f"{calculate_median(stat['readv_sizes']):>16} "
                    f"{stat['writev_calls']:>12} {stat['total_writev_bytes']:>12} {stat['max_writev_bytes']:>16} "
                    f"{calculate_median(stat['writev_sizes']):>16}\n")
        else:
            f.write(f"{'PID':>6} {'Task':>30} {'Package':>40} {'Read Calls':>12} {'Total Read':>12} "
                    f"{'Max Read':>16} {'Median Read':>16} "
                    f"{'Write Calls':>12} {'Total Write':>12} {'Max Write':>16} {'Median Write':>16}\n")
            f.write("=" * 200 + "\n")
            for pid, stat in stats.items():
                task_name, package_name = task_info.get(pid, ('bitbake_process', ''))
                f.write(
                    f"{pid:>6} {task_name:>30} {package_name:>40} {stat['read_calls']:>12} "
                    f"{stat['total_read_bytes']:>12} {stat['max_read_bytes']:>16} "
                    f"{calculate_median(stat['read_sizes']):>16} "
                    f"{stat['write_calls']:>12} {stat['total_write_bytes']:>12} {stat['max_write_bytes']:>16} "
                    f"{calculate_median(stat['write_sizes']):>16}\n")


def load_task_info(tasks_file):
    task_info = {}
    current_task_name = None
    with open(tasks_file, 'r') as f:
        for line in f:
            if line.startswith('do_'):
                current_task_name = line.strip()
            else:
                parts = line.split()
                if len(parts) >= 3:
                    package = parts[0]
                    pid = int(parts[1])
                    task_info[pid] = (current_task_name, package)
    return task_info


def process_statistics(log_file):
    read_pattern = re.compile(r'(\d+)\s+read\(\d+,.+,\s+\d+\)\s+=\s+(\d+)')
    write_pattern = re.compile(r'(\d+)\s+write\(\d+,.+,\s+\d+\)\s+=\s+(\d+)')
    readv_pattern = re.compile(r'(\d+)\s+readv\(\d+,.+,\s+\d+\)\s+=\s+(\d+)')
    writev_pattern = re.compile(r'(\d+)\s+writev\(\d+,.+,\s+\d+\)\s+=\s+(\d+)')
    resumed_pattern = re.compile(r'(\d+)\s+<\.\.\.\s+(\w+)\s+resumed>.*=\s+(\d+)')

    process_stats_rw = defaultdict(lambda: {'read_calls': 0, 'write_calls': 0,
                                            'read_sizes': [], 'write_sizes': [],
                                            'max_read_bytes': 0, 'max_write_bytes': 0,
                                            'total_read_bytes': 0, 'total_write_bytes': 0})
    process_stats_rwv = defaultdict(lambda: {'readv_calls': 0, 'writev_calls': 0,
                                             'readv_sizes': [], 'writev_sizes': [],
                                             'max_readv_bytes': 0, 'max_writev_bytes': 0,
                                             'total_readv_bytes': 0, 'total_writev_bytes': 0})
    with open(log_file, 'r') as f:
        for line in f:
            if read_match := read_pattern.match(line):
                pid, res_size = map(int, read_match.groups())
                process_stats_rw[pid]['read_calls'] += 1
                process_stats_rw[pid]['total_read_bytes'] += res_size
                process_stats_rw[pid]['max_read_bytes'] = max(process_stats_rw[pid]['max_read_bytes'], res_size)
                process_stats_rw[pid]['read_sizes'].append(res_size)
            elif write_match := write_pattern.match(line):
                pid, res_size = map(int, write_match.groups())
                process_stats_rw[pid]['write_calls'] += 1
                process_stats_rw[pid]['total_write_bytes'] += res_size
                process_stats_rw[pid]['max_write_bytes'] = max(process_stats_rw[pid]['max_write_bytes'], res_size)
                process_stats_rw[pid]['write_sizes'].append(res_size)
            elif readv_match := readv_pattern.match(line):
                pid, res_size = map(int, readv_match.groups())
                process_stats_rwv[pid]['readv_calls'] += 1
                process_stats_rwv[pid]['total_readv_bytes'] += res_size
                process_stats_rwv[pid]['max_readv_bytes'] = max(process_stats_rwv[pid]['max_readv_bytes'], res_size)
                process_stats_rwv[pid]['readv_sizes'].append(res_size)
            elif writev_match := writev_pattern.match(line):
                pid, res_size = map(int, writev_match.groups())
                process_stats_rwv[pid]['writev_calls'] += 1
                process_stats_rwv[pid]['total_writev_bytes'] += res_size
                process_stats_rwv[pid]['max_writev_bytes'] = max(process_stats_rwv[pid]['max_writev_bytes'], res_size)
                process_stats_rwv[pid]['writev_sizes'].append(res_size)
            elif resumed_match := resumed_pattern.match(line):
                pid, syscall, res_size = resumed_match.groups()
                pid = int(pid)
                res_size = int(res_size)
                if syscall == "readv":
                    process_stats_rwv[pid]['readv_calls'] += 1
                    process_stats_rwv[pid]['total_readv_bytes'] += res_size
                    process_stats_rwv[pid]['max_readv_bytes'] = max(process_stats_rwv[pid]['max_readv_bytes'], res_size)
                    process_stats_rwv[pid]['readv_sizes'].append(res_size)
                elif syscall == "writev":
                    process_stats_rwv[pid]['writev_calls'] += 1
                    process_stats_rwv[pid]['total_writev_bytes'] += res_size
                    process_stats_rwv[pid]['max_writev_bytes'] = max(process_stats_rwv[pid]['max_writev_bytes'],
                                                                     res_size)
                    process_stats_rwv[pid]['writev_sizes'].append(res_size)
                elif syscall == "read":
                    process_stats_rw[pid]['read_calls'] += 1
                    process_stats_rw[pid]['total_read_bytes'] += res_size
                    process_stats_rw[pid]['max_read_bytes'] = max(process_stats_rw[pid]['max_read_bytes'], res_size)
                    process_stats_rw[pid]['read_sizes'].append(res_size)
                elif syscall == "write":
                    process_stats_rw[pid]['write_calls'] += 1
                    process_stats_rw[pid]['total_write_bytes'] += res_size
                    process_stats_rw[pid]['max_write_bytes'] = max(process_stats_rw[pid]['max_write_bytes'], res_size)
                    process_stats_rw[pid]['write_sizes'].append(res_size)
    return process_stats_rw, process_stats_rwv


def main():
    args = parse_arguments()

    log_file = args.log_file
    tasks_file = args.tasks_file
    output_file_rw = 'output/process_statistics_rw.txt'
    output_file_rwv = 'output/process_statistics_rwv.txt'

    task_info = load_task_info(tasks_file)
    process_stats_rw, process_stats_rwv = process_statistics(log_file)
    write_statistics(output_file_rw, task_info, process_stats_rw)
    write_statistics(output_file_rwv, task_info, process_stats_rwv, is_rwv=True)

    print(f"read/write statistics were written to {output_file_rw}")
    print(f"readv/writev statistics were written to {output_file_rwv}")


if __name__ == '__main__':
    main()