
# read config servers
def read_file(name:str):
    try:
        with open(name, 'r', encoding='utf-8') as file:
            content = file.read()
            content = content.split()
            if len(content) != 2:
                raise ValueError(f"Количество слов в файле {name} должно быть 2 - начальный порт и количество портов")
            return int(content[0]), int(content[1])

    except ValueError as e:
        print(e)
        return None, None


def generate_and_write_strings(file_path:str, base_url:str, start_port:int, start_string:str, target_str:str, num:int):
    # Открываем файл для записи
    with open(file_path, 'w') as file:
        file.write(start_string)
        file.write('\n')
        for i in range(start_port, start_port + num):
            mirror_url = base_url.replace("n", str(i))
            file.write(f'file://.* {mirror_url}/{target_str}/PATH;downloadfilename=PATH')
            if i < start_port + num - 1:
                file.write('\n')
            else:
                file.write('"')

def generate_and_strings(out:str, base_url:str, start_port:int, start_string:str, target_str:str, num:int):
    out += start_string + '\n'

    for i in range(start_port, start_port + num):
        mirror_url = base_url.replace("n", str(i))
        tmp = f'file://.* {mirror_url}/{target_str}/PATH;downloadfilename=PATH'
        out += tmp
        if i < start_port + num - 1:
            out += '\n'
        else:
            out += '"\n\n'

    return out






if __name__ == '__main__':
    start, num = read_file('servers_params.txt')
    if start is None or num is None:
        raise ValueError(f"Ошибка с файлом параметров!")

    file_path = "./файлу.txt"
    base_url = "http://10.138.70.218:n"

    start_dl = r'SOURCE_MIRROR_URL ?= "\ '
    start_ss = r'SSTATE_MIRRORS ?= "\ '

    a = generate_and_strings(out='', base_url=base_url, start_port=start, start_string=start_dl, target_str='downloads',num=num)
    a = generate_and_strings(out=a, base_url=base_url, start_port=start, start_string=start_ss, target_str='sstate-cache',num=num)

    a += 'BB_HASHSERVE = "auto" \n'  
    a += 'BB_HASHSERVE_UPSTREAM = "<ip>:<port>" \n'   
    a += 'BB_SIGNATURE_HANDLER = "OEEquivHash" \n'   
    
    print(a)
