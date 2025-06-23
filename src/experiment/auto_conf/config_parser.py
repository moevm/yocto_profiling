import configparser

def read_from_config(file_name:str, section_name:str, variable_name:str):
    
    config = configparser.ConfigParser()
    try:
        config.read(file_name)
    except FileNotFoundError:
        print(f"Error: Config file {file_name} not found")
        return None

    try:
        value = config.get(section_name, variable_name)
    except configparser.NoSectionError:
        print(f"Error: Section {section_name} not found in config file {file_name}")
        return None
    except configparser.NoOptionError:
        print(f"Error: Variable {variable_name} not found in section {section_name} of config file {file_name}")
        return None

    if not value:
        print(f"Error: {variable_name} is not set")
        return None

    return value


def write_to_config(file_name:str, section_name:str, variable_name:str, variable_value:any):
    
    config = configparser.ConfigParser()
    
    try:
        config.read(file_name)
    except FileNotFoundError:
        print(f"Error: Config file {file_name} not found")
        return None
    
    try:
        config.set(section_name, variable_name, variable_value)
    except configparser.NoSectionError:
        print(f"Error: Section {section_name} not found in config file {file_name}")
        return None
    
    try:
        with open(file_name, 'w') as configfile:
            config.write(configfile)
    except PermissionError:
        print(f"Error: Permission denied. Cannot write to config file {file_name}")
        return None
    
def print_config(file_name:str):
    config = configparser.ConfigParser()
    try:
        config.read(file_name)
    except FileNotFoundError:
        print(f"Error: Config file {file_name} not found")
        exit(1)

    for section in config.sections():
        print(f"[{section}]")
        for option, value in config.items(section):
            print(f"{option} = {value}")
    

if __name__ == '__main__':

    '''
    Examples of function usage.
    '''
    print_config('experiment.conf')

    var = read_from_config('experiment.conf', 'SSH', 'cache_ip')
    if var is not None:
        print (var)
    else:
        print('Something wrong...')
        exit(1)
    
    
    # write_to_config('experiment.conf', 'SSH', 'cache_ip', var + '_test')
