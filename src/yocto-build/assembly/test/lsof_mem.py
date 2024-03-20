import psutil
def get_memory_maps(pid):
    process = psutil.Process(pid)
    memory_maps = process.memory_maps()
    for map_info in memory_maps:
        print(map_info)

for proc in psutil.process_iter(['pid', 'name']):
    try:
        get_memory_maps(proc.pid)
    except:
        print(f'no map info of {proc.pid}')
