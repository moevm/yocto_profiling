import psutil

# Получаем список всех сетевых соединений на системе
connections = psutil.net_connections(kind='all')
for conn in connections:
    print(f"Family: {conn.family}, Local Address: {conn.laddr}, Remote Address: {conn.raddr}, Status: {conn.status}")
