import re
import os

from config_parser import read_from_config

# def read_server_file(name:str):
#     try:
#         with open(name, 'r', encoding='utf-8') as file:
#             content = file.read()
#             content = content.split()
#             if len(content) != 2:
#                 raise ValueError(f"The number of words in the file {name} should be 2 - the initial port and the number of ports")
#             return int(content[0]), int(content[1])

#     except ValueError as e:
#         print(e)
#         return None, None
    

# def read_hash_file(name:str):
#     ip_pattern = re.compile(r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
#     try:
#         with open(name, 'r', encoding='utf-8') as file:
#             content_raw = file.read()
#             content = content_raw.split(':')
#             if len(content) != 2:
#                 raise ValueError(f"The file {name} should have 2 parameters separated by : -- ip and port of the hash server")
#             if not ip_pattern.match(content[0]):
#                 raise ValueError(f"IP address {content[0]} in the file {name} is invalid")
#             try:
#                 port_num = int(content[1])
#             except ValueError:
#                 raise ValueError(f"Port {content[1]} in the file {name} is invalid")

#             if port_num is None or port_num < 1024:
#                 raise ValueError(f"Port {content[1]} in the file {name} is invalid")
    
#             return content_raw

#     except ValueError as e:
#         print(e)
#         return None


def generate_strings(out:str, base_url:str, start_port:int, start_string:str, target_str:str, num:int):
    out += start_string + '\n'
    for i in range(start_port, start_port + num):
        mirror_url = base_url.replace("n", str(i))
        tmp = f'file://.* {mirror_url}/server_folder_{i}/{target_str}/PATH;downloadfilename=PATH'
        out += tmp
        if i < start_port + num - 1:
            out += ' \\ \n'
        else:
            out += '"\n\n'

    return out

def compose_settings_string(base_url, start, num, hash_ip_port):
    # start, num = read_server_file('servers_params.txt')

    try:
        start = int(start)
    except:
        start = None

    try:
        num = int(num)
    except:
        num = None


    if start is None or num is None:
        raise ValueError(f"Error with the cache parameters file!")
    
    # hash_ip_port =  read_hash_file('hash_params.txt')
    if hash_ip_port is None:
        raise ValueError(f"Error with the hash parameters file!")
        

    start_ss = r'SSTATE_MIRRORS ?= "\ '
    ret = ''
    ret = generate_strings(out=ret, base_url=base_url, start_port=start, start_string=start_ss, target_str='sstate-cache', num=num)

    ret += 'BB_HASHSERVE = "auto" \n'  
    ret += f'BB_HASHSERVE_UPSTREAM = "{hash_ip_port}" \n'   
    ret += 'BB_SIGNATURE_HANDLER = "OEEquivHash" \n'   

    return ret

#  not used, but useful for debugging
def remove_comments(filename):
    temp_filename = filename + ".tmp"

    with open(filename, "r") as input_file, open(temp_filename, "w") as output_file:
        for line in input_file:
            if not line.startswith("#") and len(line) > 1:
                output_file.write(line)
    os.rename(temp_filename, filename)

def remove_comments_and_write_settings(filename, settings):
    temp_filename = filename + ".tmp"

    with open(filename, "r") as input_file, open(temp_filename, "w") as output_file:
        lines = input_file.readlines()  
        for i, line in enumerate(lines):  
            if not line.startswith("#") and len(line) > 1:
                output_file.write(line)
            if i == len(lines) - 2:  
                output_file.write(settings + "\n")  
    os.rename(temp_filename, filename)

if __name__ == '__main__':

    config_file_name = 'experiment.conf'

    cache_ip = read_from_config(file_name=config_file_name, section_name='SSH', variable_name='cache_ip')
    base_url = f"http://{cache_ip}:n"  # ip of the CACHE server -- it's working just in case all servers are hosted on a single PC
    cache_start_port = read_from_config(file_name=config_file_name, section_name='SERVERS', variable_name='cache_start_port')
    cache_num_port = read_from_config(file_name=config_file_name, section_name='SERVERS', variable_name='cache_num_port')
  
    hash_ip = read_from_config(file_name=config_file_name, section_name='SSH', variable_name='hash_ip')
    hash_port = read_from_config(file_name=config_file_name, section_name='SERVERS', variable_name='hash_port')

    hash_ip_port = f'{hash_ip}:{hash_port}'

    settings = compose_settings_string(base_url=base_url, start=cache_start_port, num=cache_num_port, hash_ip_port=hash_ip_port)
    print(settings)
    remove_comments_and_write_settings("./conf/local.conf", settings)


    '''
    The presence of the `servers_params.txt` file is required, which will contain one line - the initial port and the number of servers.
        EX: 9000 5

    The presence of the `hash_params.txt` file is required, which will contain one line - ip:port of hash server
        EX: 10.138.70.6:9999
    '''