import os
import re
import argparse
from src.common.analysis.statistics_analyzer.src.log_iterator import log_files_iterator, log_iterator


all_metrics = ['PID', 'Elapsed time', 'utime', 'stime', 'cutime', 'cstime', 'IO rchar', 'IO wchar', 'IO syscr',
               'IO syscw', 'IO read_bytes', 'IO write_bytes', 'IO cancelled_write_bytes', 'rusage ru_utime',
               'rusage ru_stime', 'rusage ru_maxrss', 'rusage ru_minflt', 'rusage ru_majflt', 'rusage ru_inblock',
               'rusage ru_oublock', 'rusage ru_nvcsw', 'rusage ru_nivcsw', 'Child rusage ru_utime',
               'Child rusage ru_stime',
               'Child rusage ru_maxrss', 'Child rusage ru_minflt', 'Child rusage ru_majflt', 'Child rusage ru_inblock',
               'Child rusage ru_oublock', 'Child rusage ru_nvcsw', 'Child rusage ru_nivcsw']

all_tasks = ['do_collect_spdx_deps', 'do_compile', 'do_compile_ptest_base', 'do_configure', 'do_configure_ptest_base',
             'do_create_runtime_spdx',
             'do_create_spdx', 'do_deploy_source_date_epoch', 'do_fetch', 'do_install', 'do_install_ptest_base',
             'do_package', 'do_package_qa',
             'do_package_write_rpm', 'do_packagedata', 'do_patch', 'do_populate_lic', 'do_populate_sysroot',
             'do_prepare_recipe_sysroot',
             'do_recipe_qa', 'do_unpack', 'do_write_config', 'do_generate_toolchain_file']


def create_parser_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--timestamp", type=str, help="time stamp for log files")
    parser.add_argument("-b", "--build_index", type=int, help="add specified build index")
    parser.add_argument("-p", "--poky_path", type=str, help="poky directory path", required=True)
    args = parser.parse_args()
    return args


class Parser:
    def __init__(self, poky_path):  # добавляем информацию о pid
        self.info = {}
        self.timeline = {}
        self.queue = {}
        self.skipped_info = {}
        self.queue_path = os.path.join(poky_path, 'build/queue')
        self.skip_path = os.path.join(poky_path, 'build/skip')
        self.queue_analize()
        self.skip_analize()


    def skip_analize(self):
        with open(self.skip_path, 'r') as file:
            lines = file.readlines()
        
        for line in lines:
            timestamp, message = line.split(': ')
            timestamp = round(float(timestamp))

            if not timestamp in self.skipped_info:
                self.skipped_info.update({timestamp: set([message])})
            else:
                self.skipped_info[timestamp].update([message])

    def queue_analize(self):
        with open(self.queue_path, 'r') as file:
            lines = file.readlines()
        lines = list(filter(lambda x: x != '\n', lines))
        
        for line in lines:
            timestamp, tasks = line.split(': ')
            tasks = tasks.replace('{', '')
            tasks = tasks.replace('}', '')
            tasks = tasks.replace('\n', '')
            tasks = tasks.split(', ')
            tasks = set(tasks)

            timestamp = round(float(timestamp.replace('_buildable', '')))

            if not timestamp in self.queue:
                self.queue.update({timestamp: {'tasks': tasks}})
            else:
                self.queue[timestamp]['tasks'].update(tasks)
        
        
        for timestamp in self.queue:
            task_types = {}
            for task in self.queue[timestamp]['tasks']:
                task_type = task[task.rfind(':') + 1: task.rfind("'") :]
                    
                if not task_type in task_types:
                    task_types.update({task_type: 1})
                else:
                    task_types.update({task_type: task_types.get(task_type) + 1})
            self.queue[timestamp].update({'task_types': task_types})

    def add_info(self, target_info, pkg_name, task_type=None):
        if pkg_name not in target_info:
            target_info[pkg_name] = {}
        if task_type and task_type not in target_info[pkg_name]:
            target_info[pkg_name].update({task_type: {}})

    def get_data_from_buildstats(self, path):  # путь до buildstats/<timestamp>
        for log_file in log_files_iterator(path):
            timeline_files = ['reduced_proc_stat.log', 'reduced_proc_meminfo.log', 'reduced_proc_diskstats.log', 'monitor_disk.log']
            if os.path.basename(log_file) in timeline_files:
                self.parse_timeline_file(log_file)
            else:
                package_dir = os.path.dirname(log_file)
                if not os.path.basename(package_dir).endswith('reduced_proc_pressure') and all(
                        os.path.isfile(os.path.join(package_dir, f)) for f in os.listdir(package_dir)):
                    self.parse_buildstats_file(log_file)


    # при итерировании по папкам вызываем метод add_package_info, подавая путь до файлов "do_*"
    # парсинг данных из build/tmp/buildstats/<временная метка>/<имя пакета>/<имя файла>
    def parse_buildstats_file(self, path):
        ignore_list = ['Event', 'Status']
        pkg_name, task_type = '', ''
        package_info = {}
        for line in log_iterator(path):
            metric, value = line.split(': ')
            value = (re.split(" |\n", value))[0]
            if value.startswith('do_'):
                task_type = value
                pkg_name = metric
                self.add_info(self.info, pkg_name, task_type)
            else:
                if metric not in ignore_list:
                    package_info.update({metric: value})
        self.info[pkg_name].update({task_type: package_info})

    def get_tasks_for_timeline(self):
        for time, info in self.timeline.items():
            for package in self.info:
                for task in self.info[package]:
                    if time > float(self.info[package][task]['Started']) and time < float(self.info[package][task]['Ended']):
                        self.timeline[time]['tasks'].append(f'{package}.{task}')

    def parse_timeline_file(self, path):
        filename = os.path.basename(path)
        if filename == 'reduced_proc_stat.log':
            self.parse_cpu_timeline(path)
        elif filename == 'reduced_proc_meminfo.log':
            self.parse_ram_timeline(path)

    def parse_ram_timeline(self, path):
        current_timestamp = 0
        for index, line in enumerate(log_iterator(path)):
            if index % 3 == 0:
                current_timestamp = int(line.replace('\n', ''))
            if index % 3 == 1:
                if not current_timestamp in self.timeline:
                    self.timeline[current_timestamp] = {'cpu': None, 'io': None, 'ram': None, 'tasks': []}
                values = list(map(float, line.split(' ')))
                self.timeline[current_timestamp]['ram'] = (values[0] - values[1])/values[0]

    def parse_cpu_timeline(self, path):
        current_timestamp = 0
        for index, line in enumerate(log_iterator(path)):
            if index % 3 == 0:
                current_timestamp = int(line.replace('\n', ''))
            if index % 3 == 1:
                if not current_timestamp in self.timeline:
                    self.timeline[current_timestamp] = {'cpu': None, 'io': None, 'ram': None, 'tasks': []}
                values = list(map(float, line.split(' ')))
                self.timeline[current_timestamp]['cpu'] = values[0] + values[1]
                self.timeline[current_timestamp]['io'] = values[2]

    def write_data_about_task(self, task_type, metrics=None):
        with open(task_type + '.log', 'w') as file:
            if not metrics:
                metrics = all_metrics
            file.write('Package, ' + (', '.join(metrics)) + '\n')
            for package_name, package_data in self.info.items():
                if task_type in package_data.keys():
                    data = [package_name]
                    for metric in metrics:
                        data.append(self.info.get(package_name).get(task_type).get(metric, 'None'))
                    file.write((', '.join(data)) + '\n')  # для вызова нужны данные со всех пакетов


    def write_data_about_package(self, pkg_name, metrics=None):
        if not metrics:
            metrics = all_metrics
        with open(pkg_name + '.log', 'w') as file:
            file.write('Tasktype, ' + (', '.join(all_metrics)) + '\n')
            for task_type, task_info in self.info.get(pkg_name).items():
                data = [task_type]
                for metric in metrics:
                    data.append(task_info.get(metric, 'None'))
                file.write((', '.join(data)) + '\n')


    def write_data_about_all_packages(self):
        for pkg_name in self.info:
            self.write_data_about_package(pkg_name)


def main():  # пример
    args = create_parser_args()
    timestamp = ''
    timestamp_list = []
    poky_buildstats_path = os.path.join(args.poky_path, 'build/tmp/buildstats')
    tree = list(os.walk(poky_buildstats_path))
    for item in tree:
        if item[0] == poky_buildstats_path:
            timestamp_list = item[1]
    timestamp_list.sort(reverse=True)

    if args.timestamp is None and args.build_index is None:
        print('No timestamp or build index specified')
        return
    elif args.timestamp is not None and args.build_index is not None:
        print("Specify only timestamp or only build index")
        return
    if args.timestamp:
        if args.timestamp in timestamp_list:
            timestamp = args.timestamp
        else:
            print('No such timestamp')
            return
    else:
        if len(timestamp_list) > args.build_index:
            timestamp = timestamp_list[args.build_index]
        else:
            print('No such build index')
            return

    parser = Parser(args.poky_path)
    parser.get_data_from_buildstats(os.path.join(args.poky_path, 'build/tmp/buildstats', timestamp))
    parser.write_data_about_all_packages()
    for task_type in all_tasks:
        parser.write_data_about_task(task_type)


if __name__ == '__main__':
    main()
