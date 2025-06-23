### Description of how psutil works, implementing the core functionality of lsof
Important clarification – almost all Python programs using psutil must be run with superuser privileges, since the library works with information obtained from procfs.

#### 1) lsof -p <pid>
**psutil.Process.open_files()** – This function returns a list of open files for the specified process. You can use this function to get similar information as shown by the command `lsof -p <pid>`.  
**Example program:**
```python
import psutil

# Get list of processes
for proc in psutil.process_iter(['pid', 'name']):
    try:
        # Get file information for each process
        files = proc.open_files()
        if files:
            print(f"Process ID: {proc.pid}, Name: {proc.info['name']}")
            for file in files:
                print(f"\tFile Descriptor: {file.fd}, Path: {file.path}")
    except psutil.NoSuchProcess:
        pass
```
**Example output:**
```
...
Process ID: 6150, Name: chrome
	File Descriptor: 5, Path: /opt/google/chrome/icudtl.dat
	File Descriptor: 6, Path: /opt/google/chrome/v8_context_snapshot.bin
	File Descriptor: 7, Path: /opt/google/chrome/chrome_100_percent.pak
	File Descriptor: 8, Path: /opt/google/chrome/chrome_200_percent.pak
	File Descriptor: 9, Path: /opt/google/chrome/locales/en-US.pak
	File Descriptor: 10, Path: /opt/google/chrome/resources.pak
	File Descriptor: 18, Path: /opt/google/chrome/v8_context_snapshot.bin
	File Descriptor: 29, Path: /home/oumuamua/.config/google-chrome/Dictionaries/en-US-10-1.bdic
	File Descriptor: 30, Path: /home/oumuamua/.config/google-chrome/Subresource Filter/Indexed Rules/36/9.49.1/Ruleset Data
	File Descriptor: 31, Path: /home/oumuamua/.config/google-chrome/optimization_guide_model_store/25/E6DC4029A1E4B4C1/73FC7A4E3D58C314/visual_
...
```

#### 2) lsof -i  
**psutil.Process.connections()** – This function returns a list of all network connections for the specified process. You can use this function to get similar network connection information as shown by `lsof -i`.  
**Example program:**
```python
import psutil

for proc in psutil.process_iter(['pid', 'name']):
    try:
        # Get network connection information for each process
        connections = proc.connections()
        if connections:
            print(f"Process ID: {proc.pid}, Name: {proc.info['name']}")
            for conn in connections:
                print(f"\tLocal Address: {conn.laddr}, Remote Address: {conn.raddr}, Status: {conn.status}")
    except psutil.NoSuchProcess:
        pass
```

**Example output:**
```
...
Process ID: 5130, Name: chrome
	Local Address: addr(ip='10.138.70.4', port=34880), Remote Address: addr(ip='64.233.164.188', port=5228), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=38180), Remote Address: addr(ip='198.252.206.25', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=49138), Remote Address: addr(ip='149.154.167.99', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=47598), Remote Address: addr(ip='74.125.131.95', port=443), Status: NONE
	Local Address: addr(ip='10.138.70.4', port=60588), Remote Address: addr(ip='31.184.215.216', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=53476), Remote Address: addr(ip='87.240.129.131', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=54728), Remote Address: addr(ip='64.233.165.94', port=443), Status: NONE
	Local Address: addr(ip='10.138.70.4', port=33133), Remote Address: addr(ip='108.177.14.95', port=443), Status: NONE
	Local Address: addr(ip='10.138.70.4', port=59500), Remote Address: addr(ip='140.82.112.25', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=47926), Remote Address: addr(ip='149.154.167.99', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=38946), Remote Address: addr(ip='108.177.14.102', port=443), Status: NONE
	Local Address: addr(ip='10.138.70.4', port=57200), Remote Address: addr(ip='140.82.112.22', port=443), Status: ESTABLISHED
	Local Address: addr(ip='10.138.70.4', port=37248), Remote Address: addr(ip='64.233.164.101', port=443), Status: NONE
...
```

#### 3) Another equivalent of lsof -i  
**psutil.net_connections(kind='all')** – This function returns a list of all network connections on the system.  
**Example program:**
```python
import psutil

# Get list of all network connections on the system
connections = psutil.net_connections(kind='all')
for conn in connections:
    print(f"Family: {conn.family}, Local Address: {conn.laddr}, Remote Address: {conn.raddr}, Status: {conn.status}")
```

**Example output:**
```
...
Family: 1, Local Address: , Remote Address: , Status: NONE
Family: 1, Local Address: /run/systemd/journal/stdout, Remote Address: , Status: NONE
Family: 1, Local Address: , Remote Address: , Status: NONE
Family: 1, Local Address: , Remote Address: , Status: NONE
Family: 2, Local Address: addr(ip='127.0.0.53', port=53), Remote Address: (), Status: LISTEN
Family: 1, Local Address: , Remote Address: , Status: NONE
...
```

#### 4) lsof -p <pid> | grep mem  
**process.memory_maps()** – to get information about memory-mapped files for the specified process.  
**Example program:**
```python
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
```

**Example output:**
```
...
pmmap_grouped(path='/dev/shm/.com.google.Chrome.2QIQHq', rss=262144, size=262144, pss=131072, shared_clean=0, shared_dirty=262144, private_clean=0, private_dirty=0, referenced=262144, anonymous=0, swap=0)
pmmap_grouped(path='/dev/shm/.com.google.Chrome.WFGgws', rss=262144, size=262144, pss=131072, shared_clean=0, shared_dirty=262144, private_clean=0, private_dirty=0, referenced=262144, anonymous=0, swap=0)
...
```

#### 5) lsof -d  
This command allows finding out which folders and files are open in a certain directory (but not in its subdirectories) – it takes an absolute or relative path as an argument.

```python
import psutil
import os

def lsof_d(directory_path):
    for proc in psutil.process_iter():
        try:
            files = proc.open_files()
            for file in files:
                if directory_path in file.repo_path:
                    print(f"PID: {proc.pid} - File: {file.repo_path}")
        except psutil.NoSuchProcess:
            pass

# dir = os.getcwd()  # get working directory
dir = '/home'
# print(f"lsod +d for directory: {dir}")
lsof_d(dir)
```

**Example output:**
```
...
PID: 11159 - File: /home/oumuamua/.config/google-chrome/Subresource Filter/Indexed Rules/36/9.49.1/Ruleset Data
PID: 11159 - File: /home/oumuamua/.config/google-chrome/optimization_guide_model_store/25/E6DC4029A1E4B4C1/73FC7A4E3D58C314/visual_model_desktop.tflite
PID: 11159 - File: /home/oumuamua/.config/google-chrome/Subresource Filter/Indexed Rules/36/9.49.1/Ruleset Data
...
```
