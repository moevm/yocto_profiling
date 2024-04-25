# Создание http кэш сервера 
### Локальная подготовка 
1) Необходимо произвести сборку образа
2) Скопировать папки poky/build/dowloads и poky/build/sstate-cache в какую-то стороннюю директорию
### Запуск сервера 
Для запуска сервера написана python программа, которая запускает ftp сервер на порте 2024 (это не очень важно на каком, просто уточнение)
```py
import os
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
authorizer = DummyAuthorizer()
authorizer.add_anonymous(os.getcwd())
handler = FTPHandler
handler.authorizer = authorizer
server = FTPServer(("127.0.0.1", 2024), handler)
server.serve_forever()

# обхов дерева текущей директории и выгрузка файлов
for root, dirs, files in os.walk(os.getcwd()):
    for file in files:
        with open(os.path.join(root, file), 'rb') as f:
            handler.on_file_received(f)

    for dir in dirs:
        handler.on_mkdir(dir)
```
Программа имеет исключительно демонстрационный характер! Для интеграции в систему сборки ее нужно дорабатывать
### Тестирование поднятого сервера
Поскольку ftp сервер в базе не имеет web интерфейса, то открыть его в браузере не получится. Потому стоит написать порграмму, которая будет подключаться к созданному серверу.  
Реализуем следующий функционал - проргамма подключается к серверу, проходит дерево сервера и выводит встреченный файлы и папки (таким образом бцудет продемонстрировано то, что ftp сервер действительно содержит файлы кэша и то, что мы можем обратиться к ним):  
```py
from ftplib import FTP

def list_files_in_dir(ftp, path):
    files = []
    ftp.cwd(path)
    ftp.retrlines('LIST', lambda line: files.append(line.split()[-1]))
    for file in files:
        if file.startswith('.'):  # Пропускаем скрытые файлы
            continue
        if '.' in file:  
            print(path + '/' + file)
        else:  # Если директория
            list_files_in_dir(ftp, path + '/' + file)

# Подключение к FTP серверу
ftp = FTP()
ftp.connect('localhost', 2024)  
ftp.login()  
files = ftp.nlst()

list_files_in_dir(ftp, '/')

ftp.quit()

```
Программа имеет исключительно демонстрационный характер! Для интеграции в систему сборки ее нужно дорабатывать

#### Скринкаст демонстрации работы программы:  
Начало вывод:  
![Screenshot from 2024-04-25 21-24-13](https://github.com/moevm/os_profiling/assets/90711883/6bf49fc2-c36c-478f-9469-8f52cd5c450f)  
Конец вывода:  
![Screenshot from 2024-04-25 21-25-33](https://github.com/moevm/os_profiling/assets/90711883/57794052-6c00-40e4-8a5f-f2358aabddf2)


