import os
import sys
import re
from difflib import SequenceMatcher


class Parser:
    def __init__(self): #для гарантии добавления всех пакетов нужно сделать обход по work, заодно добавляем сразу pid
        self.info = {}
        tree = list(os.walk('poky/build/tmp/work'))
        for directory in tree:
            for file in directory[2]:
                if file.startswith('log.do_') and file[-1].isdigit:
                    pkg_name = (directory[0].split('/'))[-3]
                    task_type = file.split('.')[1]
                    self.add_package_info(pkg_name, task_type)
                    self.collect_pid(directory[0] + '/' + file)


    def add_package_info(self, pkg_name, task_type=None): #целесообразно сначала добавить все пакеты из build/tmp/work
        if pkg_name not in self.info.keys():
            self.info.update({pkg_name: {}})
        if task_type and task_type not in self.info.get(pkg_name).keys():
            self.info.get(pkg_name).update({task_type: {}}) 


    #при итерировании по папкам вызываем метод add_package_info, подавая путь до файлов "do_*"
    #парсинг данных из build/tmp/buildstats/<временная метка>/<имя пакета>/<имя файла>
    def parse_buildstats_file(self, path):
        ignore_list = ['Event', 'Started', 'Ended', 'Status']
        pkg_name, task_type = '', ''
        with open(path, 'r') as file:
            for line in file:
                metric, value = line.split(': ')
                value = (re.split(" |\n", value))[0]
                if value.startswith('do_'):
                    task_type = value
                    while metric not in self.info.keys():
                        metric = metric[: -1 :]
                    pkg_name = metric
                    print(metric)
                    self.add_package_info(metric, task_type)
                else:
                    if metric not in ignore_list:
                        self.info.get(pkg_name).get(task_type).update({metric: value})


    #парсинг данных из build/tmp/work/<MULTIARCH_TARGET_SYS>/<имя пакета>/<версия>/temp/log.do_*.pid
    def collect_pid(self, path): #аналогично относительный путь до файла, предполагается что относительный путь содержит по крайней мере <имя пакета>/<версия>/temp/log.do_*.pid
        temp = path.split('/')
        file_name = temp[-1]
        pkg_name = temp[-4]
        task_type = file_name.split('.')[-2]
        self.add_package_info(pkg_name, task_type)
        pid = file_name.split('.')[-1]
        self.info.get(pkg_name).get(task_type).update({"pid": pid})


def main(): #пример
    parser = Parser()
    parser.parse_buildstats_file('poky/build/tmp/buildstats/20240212085739/acl-2.3.1-r0/do_collect_spdx_deps')
    parser.parse_buildstats_file('poky/build/tmp/buildstats/20240212085739/acl-native-2.3.1-r0/do_collect_spdx_deps')
    print(parser.info.get('acl'))
    print()
    print(parser.info.get('acl-native'))
    print(len(parser.info))


if __name__ == '__main__':
    main()



