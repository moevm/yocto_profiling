import os
import sys
import re
from log_iterator import LogFilesIterator, LogIterator

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


class Parser:
    def __init__(self):  # добавляем информацию о pid
        self.info = {}
        self.pid_info = {}
        log_files_iterator = LogFilesIterator('poky/build/tmp/work',
                                              lambda x: x.startswith('log.do_') and x[-1].isdigit())
        for log_file in log_files_iterator:
            pkg_name = log_file.split('/')[-3]
            task_type = log_file.split('.')[-2]
            self.add_pid_info(pkg_name, task_type)
            self.collect_pid(log_file)

    def add_package_info(self, pkg_name, task_type=None):
        if pkg_name not in self.info.keys():
            self.info.update({pkg_name: {}})
        if task_type and task_type not in self.info.get(pkg_name).keys():
            self.info.get(pkg_name).update({task_type: {}})

    def add_pid_info(self, pkg_name, task_type=None):
        if pkg_name not in self.pid_info.keys():
            self.pid_info.update({pkg_name: {}})
        if task_type and task_type not in self.pid_info.get(pkg_name).keys():
            self.pid_info.get(pkg_name).update({task_type: {}})

    def get_data_from_buildstats(self, path):  # путь до buildstats/<timestamp>
        log_files_iterator = LogFilesIterator(path)
        for log_file in log_files_iterator:
            package_dir = os.path.dirname(log_file)
            if not os.path.basename(package_dir).endswith('reduced_proc_pressure') and all(os.path.isfile(os.path.join(package_dir, f)) for f in os.listdir(package_dir)):
                self.parse_buildstats_file(log_file)



    # при итерировании по папкам вызываем метод add_package_info, подавая путь до файлов "do_*"
    # парсинг данных из build/tmp/buildstats/<временная метка>/<имя пакета>/<имя файла>
    def parse_buildstats_file(self, path):
        ignore_list = ['Event', 'Started', 'Ended', 'Status']
        pkg_name, task_type = '', ''
        log_iterator = LogIterator(path)
        for line in log_iterator:
            metric, value = line.split(': ')
            value = (re.split(" |\n", value))[0]
            if value.startswith('do_'):
                task_type = value
                while (metric not in self.pid_info.keys() and any(symbol.isdigit() for symbol in metric)) or metric[
                    -1] == '-':
                    metric = metric[: -1:]
                pkg_name = metric
                self.add_package_info(metric, task_type)
                if pkg_name in self.pid_info.keys() and task_type in self.pid_info.get(
                        pkg_name).keys():  # пытаемся сопоставить PID данной задаче
                    self.info.get(pkg_name).get(task_type).update(
                        {"PID": self.pid_info.get(pkg_name).get(task_type).get("PID", None)})
            else:
                if metric not in ignore_list:
                    self.info.get(pkg_name).get(task_type).update({metric: value})

    # парсинг данных из build/tmp/work/<MULTIARCH_TARGET_SYS>/<имя пакета>/<версия>/temp/log.do_*.pid

    def collect_pid(self,
                    path):  # аналогично относительный путь до файла, предполагается что относительный путь содержит по крайней мере <имя пакета>/<версия>/temp/log.do_*.pid
        temp = path.split('/')
        file_name = temp[-1]
        pkg_name = temp[-4]
        task_type = file_name.split('.')[-2]
        self.add_pid_info(pkg_name, task_type)
        pid = file_name.split('.')[-1]
        self.pid_info.get(pkg_name).get(task_type).update(
            {"PID": pid})  # PID имеется для подавляющего количества задач, но не для всех

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
            file.close()

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
            file.close()

    def write_data_about_all_packages(self):
        for pkg_name in self.info:
            self.write_data_about_package(pkg_name)


def main():  # пример
    timestamp = ''
    timestamp_list = []
    tree = list(os.walk('poky/build/tmp/buildstats'))
    for item in tree:
        if item[0] == 'poky/build/tmp/buildstats':
            print(222)
            timestamp_list = item[1]
    timestamp_list.sort(reverse=True)
    print(timestamp_list)

    if len(sys.argv) < 2:
        print('No timestamp or build index specified')
        return
    if sys.argv[1] == '-b':
        if len(timestamp_list) >= int(sys.argv[2]):
            timestamp = timestamp_list[int(sys.argv[2])]
        else:
            print('No such build index')
            return
    else:
        if sys.argv[1] in timestamp_list:
            timestamp = sys.argv[1]
        else:
            print('No such timestamp')
            return


    parser = Parser()
    parser.get_data_from_buildstats('poky/build/tmp/buildstats/' + timestamp)
    parser.write_data_about_all_packages()
    for task_type in all_tasks:
        parser.write_data_about_task(task_type)


if __name__ == '__main__':
    main()

