import os
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

def setup_ftp():
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



if __name__ == '__main__':
    setup_ftp()
