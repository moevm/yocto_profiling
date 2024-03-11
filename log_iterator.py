import os

def log_files_iterator(logs_directory, condition=None):
    for root, dirs, files in os.walk(logs_directory):
        for file in files:
            if condition is not None and not condition(file):
                continue
            yield os.path.join(root, file)


def log_iterator(log_file_path):
    with open(log_file_path, 'r') as log_file:
        for line in log_file:
            yield line
