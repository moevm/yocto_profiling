import requests
import concurrent.futures



def check_server(server: str) -> bool:
    try:
        response = requests.get(server)
        if response.status_code == 200:
            return True
    except requests.RequestException:
        pass
    return False

def sequential_check(pull_addres: list) -> list:
    available_servers = []
    for address in pull_addres:
        if check_server(address):
            available_servers.append(address)

    return available_servers


def parallel_check(pull_addres: list) -> list:
    available_servers = []

    # number of parallel requests = number of processors in the system multiplied by 5.
    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = {executor.submit(check_server, server): server for server in pull_addres}
        for future in concurrent.futures.as_completed(futures):
            server = futures[future]
            if future.result():
                available_servers.append(server)

    return available_servers


if __name__ == '__main__':
    ip_list = [f'http://0.0.0.0:{i}' for i in range(0, 10000, 1)]
    # print(ip_list)

    start_time = time.time()

    available_servers = sequential_check(ip_list)
    print("Доступные серверы:")
    for address in available_servers:
        print(address)

    end_time = time.time()
    print(f'Затрачено {end_time-start_time}')
    # Затрачено 5.140434265136719
    
    start_time = time.time()
    available_servers1 = parallel_check(ip_list)
    

    print("Доступные серверы 1:")
    for address in available_servers1:
        print(address)

    end_time = time.time()
    print(f'Затрачено {end_time-start_time}')
    # Затрачено 17.395881414413452


