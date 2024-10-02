        import socket
        mirrors = self.data.getVar('SSTATE_MIRRORS')
      
        parts = mirrors.split()
        result_list = [' '.join(parts[i:i+2]) for i in range(0, len(parts), 2)]


        with open('mirrors_self.data.txt', 'a') as file:
            for i in range(len(result_list)):
                file.write(str(result_list[i]) + '\n')

        def is_port_open(address, port, timeout=1):
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.settimeout(timeout)
                result = sock.connect_ex((address, port))
                return result == 0

        def extract_address_and_port(url):
            protocol_end = url.find('://')
            if protocol_end == -1:
                return None, None
            address_start = protocol_end + 3
            address_end = url.find(':', address_start)
            if address_end == -1:
                return None, None
            address = url[address_start:address_end]
            port_end = url.find('/', address_end)
            if port_end == -1:
                port_end = url.find(';', address_end)
            if port_end == -1:
                return None, None
            port = int(url[address_end + 1:port_end])
            return address, port

        filtered_result = []
        for item in result_list:
            url = item.split()[1]  # Получаем URL из строки
            address, port = extract_address_and_port(url)
            if address and port and is_port_open(address, port):
                filtered_result.append(item)


        with open('[filtered]_mirrors_self.data.txt', 'a') as file:
            for item in filtered_result:
                file.write(str(item) + '\n')
               
        output_string = ' '.join(filtered_result)

        with open('[result]_mirrors_self.data.txt', 'a') as file:
            file.write(output_string)

        self.data.setVar('SSTATE_MIRRORS', output_string)
