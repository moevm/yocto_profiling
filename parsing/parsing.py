import os
import sys
import re

class Parser:
    def __init__(self):
        self.info = dict()


    #для удаления версии и т.п.
    def get_package_name(self, old_name):
        pkg_name_words = old_name.split('-')

        new_pkg_name = []
        for word in pkg_name_words:
            if word == 'r0':
                continue
            if word.isalpha():
                new_pkg_name.append(word)
            else:
                found_letter = 0
                for symbol in word:
                    if symbol.isalpha():
                        found_letter = 1
                        break
                if found_letter == 1:
                    new_pkg_name.append(word)

        pkg_name = '-'.join(new_pkg_name)
        return pkg_name


    def add_package_info(self, pkg_name, task_type=None):
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
                    pkg_name = self.get_package_name(metric)
                    task_type = value
                    self.add_package_info(pkg_name, task_type)
                else:
                    if metric not in ignore_list:
                        self.info.get(pkg_name).get(task_type).update({metric: value})

    #парсинг данных из build/tmp/work/<MULTIARCH_TARGET_SYS>/<имя пакета>/<версия>/temp/log.do_*.pid
    def collect_pids(self, path): #аналогично относительный путь до файла
        temp = path.split('/')
        file_name = temp[-1]
        pkg_name = temp[-4]
        task_type = file_name.split('.')[-2]
        self.add_package_info(pkg_name, task_type)
        pid = file_name.split('.')[-1]
        self.info.get(pkg_name).get(task_type).update({"pid": pid})


def main(): #пример
    parser = Parser()
    parser.collect_pids('poky/build/tmp/work/core2-64-poky-linux/acl/2.3.1/temp/log.do_collect_spdx_deps.2050038')
    parser.parse_buildstats_file('poky/build/tmp/buildstats/20240212085739/acl-2.3.1-r0/do_collect_spdx_deps')
    print(parser.info)

if __name__ == '__main__':
    main()



