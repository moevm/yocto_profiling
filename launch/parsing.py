import os
import re
import argparse
from log_iterator import log_files_iterator, log_iterator


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
        self.pid_info = {}
        self.traverse_pid_directories(poky_path, 'work')
        self.traverse_pid_directories(poky_path, 'work-shared')

    def traverse_pid_directories(self, poky_path, directory):
        for log_file in log_files_iterator(os.path.join(poky_path, 'build/tmp/' + directory),
                                           lambda x: x.startswith('log.task_order')):
            if directory == 'work':
                pkg_name = log_file.split('/')[-4]
            else: 
                pkg_name = log_file.split('/')[-3]
                if pkg_name.startswith('gcc'):
                    pkg_name = 'gcc-source'
            self.collect_pid(log_file, pkg_name)

    def add_info(self, target_info, pkg_name, task_type=None):
        if pkg_name not in target_info:
            target_info[pkg_name] = {}
        if task_type and task_type not in target_info[pkg_name]:
            target_info[pkg_name].update({task_type: {}})

    def get_data_from_buildstats(self, path):  # путь до buildstats/<timestamp>
        for log_file in log_files_iterator(path):
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
                if 'gcc-source' not in metric:
                    while ((metric not in self.pid_info.keys() and any(symbol.isdigit() for symbol in metric))
                        or metric[-1] == '-'):
                        metric = metric[: -1:]
                    pkg_name = metric
                else:
                    pkg_name = 'gcc-source'
                self.add_info(self.info, pkg_name, task_type)
                if pkg_name in self.pid_info.keys() and task_type in self.pid_info.get(
                        pkg_name).keys():  # пытаемся сопоставить PID данной задаче

                    package_info.update({'PID': self.pid_info.get(pkg_name).get(task_type).get("PID", None)})
            else:
                if metric not in ignore_list:
                    package_info.update({metric: value})
        self.info[pkg_name].update({task_type: package_info})


    def collect_pid(self, path, pkg_name):
        temp = path.split('/')
        with open(path, 'r') as file:
            for line in file:
                task_type = line.split(' ')[1]
                pid = line.split(' ')[2][1: -2]
                self.add_info(self.pid_info, pkg_name, task_type)
                self.pid_info.get(pkg_name).get(task_type).update({"PID": pid})


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
