import os
import shutil


BASE_HEXADECIMAL = 16

# for main action -- copy target file to dest dir
def find_and_copy_directory(src_dir, dir_name, dest_dir):
    if not os.path.exists(src_dir):
        print(f"Sstate-cache dir ({src_dir}) does not exist.")
        return

    if not os.path.exists(dest_dir):
        print(f"Server dir({dest_dir})does not exist. creating")
        os.makedirs(dest_dir)

    for root, dirs, files in os.walk(src_dir):
        if dir_name in dirs:
            src_path = os.path.join(root, dir_name)
            dest_path = os.path.join(dest_dir, dir_name)
            shutil.copytree(src_path, dest_path)
            print(f"{dir_name} from {src_path} copy to {dest_path}")
            return

    print(f"{dir_name} does not exist in {src_dir}")

# for debug without copy
def check_dirs(src_dir, dir_name, dest_dir):
    if not os.path.exists(src_dir):
        print(f"Sstate-cache dir ({src_dir}) does not exist.")
        return
    if not os.path.exists(dest_dir):
        print(f"Server dir({dest_dir})does not exist.")
        return
    for root, dirs, files in os.walk(src_dir):
        return
    print(f'{dir_name} doesnt exist in {src_dir}')

# read config servers
def read_file(name:str):
    try:
        with open(name, 'r', encoding='utf-8') as file:
            content = file.read()
            content = content.split()
            if len(content) != 2:
                raise ValueError(f"Количество слов в файле {name} должно быть 2 - начальный порт и количество портов")
            return int(content[0]), int(content[1])

    except ValueError as e:
        print(e)
        return None, None



if __name__ == '__main__':
    iterator_dest_dir = 0
    # set parh to sstate-cache dir
    src_dir = "./sstate-cache"
    start, num = read_file('servers_params.txt')
    # print(start, num)
    if start is None or num is None:
        raise ValueError(f"Ошибка с файлом параметров!")
    for i in range(BASE_HEXADECIMAL):
        for j in range(BASE_HEXADECIMAL):
            iterator_dest_dir += 1
            iterator_dest_dir = iterator_dest_dir % num
            tmp_dir = 'server_folder_' + str(start + iterator_dest_dir) + '/sstate-cache'
            hi = str(hex(i))[2:]
            hj = str(hex(j))[2:]
            dir_name = hi+hj
            find_and_copy_directory(src_dir=src_dir, dir_name=dir_name, dest_dir=tmp_dir)
            # check_dirs(src_dir=src_dir, dir_name=dir_name, dest_dir=tmp_dir)



    print('Copy univerasl ...')
    iterator_dest_dir += 1
    iterator_dest_dir = iterator_dest_dir % num
    source_folder = "./sstate-cache/universal"
    destination_folder = f"./server_folder_{start + iterator_dest_dir}/sstate-cache"

    shutil.copytree(source_folder, os.path.join(destination_folder, "universal"))
    print(f"universal from {source_folder} copy to {destination_folder}/universal")

