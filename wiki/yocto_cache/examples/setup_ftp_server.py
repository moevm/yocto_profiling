import os
import argparse
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

def setup_ftp(path):
    authorizer = DummyAuthorizer()
    authorizer.add_anonymous(path)
    handler = FTPHandler
    handler.authorizer = authorizer
    server = FTPServer(("127.0.0.1", 2024), handler)
    server.serve_forever()

    # traversal of the current directory tree and file export
    for root, dirs, files in os.walk(path):
        for file in files:
            with open(os.path.join(root, file), 'rb') as f:
                handler.on_file_received(f)

        for dir in dirs:
            handler.on_mkdir(dir)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', type=str, default=os.getcwd(), help='Path to the folder (default: current working directory)')
    args = parser.parse_args()
    setup_ftp(args.path)
