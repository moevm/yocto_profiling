import re
import subprocess
import os



def generate_strings(base_url:str, start_port:int, target_str:str, num:int, target_working_server_port=9999) -> str:
    start_ss = '\nSSTATE_MIRRORS ?= " \\\n'

    for i in range(start_port, start_port + num):
        mirror_url = base_url.replace("n", str(i))
        tmp = f'file://.* {mirror_url}/{target_str}/PATH;downloadfilename=PATH'
        start_ss += tmp
        if i < start_port + num - 1:
            start_ss += ' \\\n'
        else:
            start_ss +=f' \ \nfile://.* { base_url.replace("n", str(target_working_server_port))}/{target_str}/PATH;downloadfilename=PATH'
            start_ss += '"'

    return start_ss


def compose_settings_string(base_url, start, num, hash_ip_port, target_working_server_port=9999):

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
        
    ret = ''

    ret += 'BB_HASHSERVE = "auto"\n'  
    ret += f'BB_HASHSERVE_UPSTREAM = "{hash_ip_port}"\n'   
    ret += 'BB_SIGNATURE_HANDLER = "OEEquivHash"\n'   

    ret += generate_strings(base_url=base_url, start_port=start, target_str='sstate-cache', num=num, target_working_server_port=target_working_server_port)

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
            if "PACKAGECONFIG" in line:
                output_file.write(settings + "\n")
                last_i = i
                break

            output_file.write(line)

        if last_i < lines_count:
            for i in range(last_i + 1, lines_count):
                output_file.write(lines[i])

    os.rename(temp_filename, filename)

if __name__ == '__main__':

    target_working_server_port = 9999
    hash_ip_port = f'0.0.0.0:{8686}'
    cache_ip =  '10.138.70.7'
    base_url = f"http://{cache_ip}:n"  # ip of the CACHE server -- it's working just in case all servers are hosted on a single PC
    cache_start_port = 8150
    cache_num_port = 50
    os.makedirs(f'./configs', exist_ok=True)


    for num in range(1, cache_num_port):
        os.makedirs(f'./{num}', exist_ok=True)
        subprocess.run(['cp', "./local.conf", f'./{num}/local.conf'])
        settings = compose_settings_string(base_url=base_url, start=cache_start_port, num=num, hash_ip_port=hash_ip_port, target_working_server_port=target_working_server_port)
        remove_comments(f"./{num}/local.conf")
        # print(settings)
        write_settings(f"./{num}/local.conf", settings)
        subprocess.run(['mv', '-f', f"./{num}", f'./configs/{num}/'])
