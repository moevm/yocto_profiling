import os
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

def setup_ftp(path):
    authorizer = DummyAuthorizer()
    authorizer.add_anonymous(os.getcwd())
    handler = FTPHandler
    handler.authorizer = authorizer
    server = FTPServer(("127.0.0.1", 2024), handler)
    server.serve_forever()

    # обхов дерева текущей директории и выгрузка файлов
    for root, dirs, files in os.walk(path):
        for file in files:
            with open(os.path.join(root, file), 'rb') as f:
                handler.on_file_received(f)

        for dir in dirs:
            handler.on_mkdir(dir)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=str, default=os.getcwd(), help='Путь к папке (по умолчанию: текущая рабочая директория)')
    args = parser.parse_args()
    setup_ftp(args.path)
