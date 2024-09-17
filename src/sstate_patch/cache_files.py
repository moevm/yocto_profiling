import os
import argparse

def create_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", type=str, required=True, help="server sources path")
    args = parser.parse_args()
    return args


def find_cache(path):
    cache_files = []
    for dirpath, _, filenames in os.walk(path):
        for filename in filenames:
            cache_files.append(os.path.join(dirpath, filename))
    return cache_files


def create_output_file(files):
    with open('index.txt', 'a') as output:
        print(files)
        for file in files:
            output.write(f'{file}\n')


if __name__ == '__main__':
    args = create_args()
    cache_files = find_cache(args.path)
    create_output_file(cache_files)
