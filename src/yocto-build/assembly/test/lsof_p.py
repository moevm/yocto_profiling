import psutil

# Получаем список процессов
for proc in psutil.process_iter(['pid', 'name']):
    try:
        # Получаем информацию о файлaх для каждого процесса
        files = proc.open_files()
        if files:
            print(f"Process ID: {proc.pid}, Name: {proc.info['name']}")
            for file in files:
                print(f"\tFile Descriptor: {file.fd}, Path: {file.path}")
    except psutil.NoSuchProcess:
        pass
