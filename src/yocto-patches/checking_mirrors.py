'''
промежуточная версия в виде python скрипта, который буду оформлять в виде патча в https://github.com/yoctoproject/poky/blob/8634e46b4040b6008410b6d77fecb5cbaec7e90e/meta/classes-global/sstate.bbclass#L729C5-L729C19
'''

import socket

def check_port(mirrors):
    for mirror in mirrors:
        port, host = int(mirror.split(':')[1]), mirror.split(':')[0]
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(5)  
            result = sock.connect_ex((host, port))
            if result == 0:
                print(f"Порт {port} на хосте {host} открыт.")
            else:
                print(f"Порт {port} на хосте {host} закрыт.")

if __name__ == "__main__":
    mirrors_list = ['0.0.0.0:8880', '0.0.0.0:8881', '0.0.0.0:8882', '0.0.0.0:8883']
    check_port(mirrors_list)
