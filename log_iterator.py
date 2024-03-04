import os
import sys


class LogFilesIterator:
    def __init__(self, logs_directory, condition=None):
        self.logs_directory = logs_directory
        if condition:
            self.log_files = [os.path.join(root, file) for root, dirs, files in os.walk(logs_directory) for file in
                              files if condition(file)]
        else:
            self.log_files = [os.path.join(root, file) for root, dirs, files in os.walk(logs_directory) for file in
                              files]
        self.current_file_index = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.current_file_index < len(self.log_files):
            current_log_file = self.log_files[self.current_file_index]
            self.current_file_index += 1
            return current_log_file
        else:
            raise StopIteration


class LogIterator:
    def __init__(self, log_file_path):
        self.log_file_path = log_file_path
        self.current_line = 0

    def __iter__(self):
        return self

    def __next__(self):
        with open(self.log_file_path, 'r') as log_file:
            lines = log_file.readlines()
            if self.current_line < len(lines):
                current_log_line = lines[self.current_line]
                self.current_line += 1
                return current_log_line
            else:
                raise StopIteration
