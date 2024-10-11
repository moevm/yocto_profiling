import re
import os

from config_parser import read_from_config


def generate_strings(out:str, base_url:str, start_port:int, start_string:str, target_str:str, num:int):
    out += start_string + '\n'
    for i in range(start_port, start_port + num):
        mirror_url = base_url.replace("n", str(i))
        tmp = f'file://.* {mirror_url}/{target_str}/PATH;downloadfilename=PATH'
        out += tmp
        if i < start_port + num - 1:
            out += ' \\ \n'
        else:
            out += '"\n\n'

    return out

def compose_settings_string(base_url, start, num, hash_ip_port):

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

def write_settings(filename, settings):
    temp_filename = filename + ".tmp"

    with open(filename, "r") as input_file, open(temp_filename, "w") as output_file:
        lines = input_file.readlines()
        lines_count = len(lines)

        last_i: int
        for i, line in enumerate(lines): 
            if "# SETTINGS" in line:
                output_file.write(settings + "\n")
                last_i = i
                break

            output_file.write(line)

        if last_i < lines_count:
            for i in range(last_i + 1, lines_count):
                output_file.write(lines[i])

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
    write_settings("./conf/local.conf", settings)
