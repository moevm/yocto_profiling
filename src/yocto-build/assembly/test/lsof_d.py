import psutil
import os

def lsof_d(directory_path):
    for proc in psutil.process_iter():
        try:
            files = proc.open_files()
            for file in files:
                if directory_path in file.path:
                    print(f"PID: {proc.pid} - File: {file.path}")
        except psutil.NoSuchProcess:
            pass

# dir = os.getcwd()  # получение рабочей директории
dir = '/home'
# print(f"lsod +d для директории: {dir}")
lsof_d(dir)
