### Task list
- [x] 1) Installing necessary packages
- [x] 2) Description of perf
- [X] 3) Description of perf stat 
- [X] 4) Description of perf mem
- [x] 5) Description of iostat
- [x] 6) Description of perf ftrace and perf trace
- [x] 7) Description of lsof
- [x] 8) Interesting programs
- [x] 9) psutil is lsof for python [Link](https://psutil.readthedocs.io/en/release-3.0.1/index.html?highlight=open%20files#psutil.Process.open_files)
- [x] 10) Strace detailed description

#### Install necessary packages
Command for **Ubuntu** 
```Bash
$ sudo apt install linux-tools-common
```
* During installation, a dependency or package conflict error may appear — in this case, **follow the advice from the terminal**, and if necessary, you can remove conflicting packages.

#### Brief description of **perf** utility commands
1) **buildid-cache** Manage the build ID cache.
2) **daemon** Run recording sessions in the background
4) **ftrace** simple wrapper for kernel ftrace functionality
5) **inject** filter to enrich (or trim) the event stream with additional info
6) **iostat** Show input/output performance metrics
7) **kallsyms** Look up symbols in the running kernel
8) **kmem** Tool for tracking/measuring kernel memory properties
9) **kvm** for tracking/measuring KVM guest OS
10) **list** List all symbolic event types
11) **lock** Analyze lock events
12) **mem** Memory profiling
13) **stat** Run command and collect performance counter stats
14) **trace** Tracing tool

I think the useful commands are `stat, iostat, mem, lock, ftrace, trace`.

#### sudo perf stat
1) -C <num process> — monitors process resources
2) -D, --delay <n> — ms delay before measurement begins after program launch
3) -a, --all-cpus — monitors all processes together
4) -p, --pid <pid> — monitors a specific process. Example: `python tt.py & sudo perf stat -p $!` launches the program as a daemon, captures its pid, and runs sudo perf stat -p.
5) -o, --output <file> — output file name (handy). Example: `python tt.py & sudo perf stat -p $! -o out.txt`
6) -v, --verbose — verbose logs (not very verbose). Example: `python tt.py & sudo perf stat -v -p $! -o output_v.txt`

The difference between v mode and regular is in [File p.5](logs/output.txt) and [File p.6](logs/output_v.txt)

#### sudo perf mem
To use sudo perf mem:
1) record — collect information
2) report — display information

When you run record with various flags, a **perf.data** file is generated.  
To read it, execute command 2 `perf mem report`, a window will open where you can see the file output:  
![image](https://github.com/moevm/os_profiling/assets/90711883/bfded735-c6f2-49be-9ec3-8c68049a7e77)

#### iostat description
Run the command to install iostat: `sudo apt install sysstat`  
The program has limited functionality, I came up with a mini-script that calls `iostat -t -x` every 0.3 seconds:
```Bash
while [ 1 ]
do
   iostat -t -x 
   sleep .3
   clear
done
```
Script result:  
![image](https://github.com/moevm/os_profiling/assets/90711883/11f1208e-9da1-433a-8cb5-4b4e6e652a29)

There’s an idea to record output changes and maybe build some graphs…

#### perf ftrace and perf trace description
1) `sudo perf trace` — nothing special, feels like a wrapper like in the [Simple ftrace scripts](cpu_tracer.md)
2) `sudo perf trace` — generates a million billion lines, feels hard to analyze reasonably:  
   ![image](https://github.com/moevm/os_profiling/assets/90711883/9d3cdf05-0f75-41c8-a9e3-618e15e00973)

#### lsof description
When running the lsof command, the output follows this structure:
```
COMMAND     PID   TID TASKCMD               USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
chrome     3633                         oumuamua  208r      REG                8,2    126400    8260929 /home/oumuamua/.config/google-chrome/Safe Browsing/UrlUws.store.4_13352470830264015
chrome     3633                         oumuamua  209u     unix 0x0000000000000000       0t0     107082 type=STREAM
chrome     3633                         oumuamua  210u     sock                0,8       0t0      90556 protocol: UNIX-STREAM
```

On an idle system, this command generates 180,000 lines — if written to a file, it results in a 30MB file  
+ Option -U allows listing all Unix domain socket files  
+ Option -c allows showing files held open by processes running specific commands (e.g., -c chrome)  
+ Option +d reveals which folders and files are open in a given directory (but not its subdirectories) — it accepts an absolute or relative path  
+ Option -p shows all files opened by the process with the specified PID (e.g., -p 1)

More complete description:
```
Defaults in parentheses; comma-separated set(s) items; dash-separated ranges.
  -?|-h list help          -a AND selections (OR)     -b avoid kernel blocks
  -c c  cmd c ^c /c/[bix]  +c w  COMMAND width (9)    +d s  dir s files
  -d s  select by FD set   +D D  dir D tree *SLOW?*   +|-e s  exempt s *RISKY*
  -i select IPv[46] files  -K [i] list|(i)gn tasKs    -l list UID numbers
  -n no host names         -N select NFS files        -o list file offset
  -O no overhead *RISKY*   -P no port names           -R list paRent PID
  -s list file size        -t terse listing           -T disable TCP/TPI info
  -U select Unix socket    -v list version info       -V verbose search
  +|-w  Warnings (+)       -X skip TCP&UDP* files     -Z Z  context [Z]
  -- end option scan     
  -E display endpoint info              +E display endpoint info and files
  +f|-f  +filesystem or -file names     +|-f[gG] flaGs 
  -F [f] select fields; -F? for help  
  +|-L [l] list (+) suppress (-) link counts < l (0 = all; default = 0)
                                        +m [m] use|create mount supplement
  +|-M   portMap registration (-)       -o o   o 0t offset digits (8)
  -p s   exclude(^)|select PIDs         -S [t] t second stat timeout (15)
  -T qs TCP/TPI Q,St (s) info
  -g [s] exclude(^)|select and print process group IDs
  -i i   select by IPv[46] address: [46][proto][@host|addr][:svc_list|port_list]
  +|-r [t[m<fmt>]] repeat every t seconds (15);  + until no files, - forever.
       An optional suffix to t is m<fmt>; m must separate t from <fmt> and
      <fmt> is an strftime(3) format for the marker line.
  -s p:s  exclude(^)|select protocol (p = TCP|UDP) states by name(s).
  -u s   exclude(^)|select login|UID set s
  -x [fl] cross over +d|+D File systems or symbolic Links
  names  select named files or files on named file systems
```

#### Python psutil
This is a Python library that implements many functions offered by command-line tools like: ps, top, lsof, netstat, ifconfig, who, df, kill, free, nice, ionice, iostat, iotop, uptime, pidof, tty, Taskset, pmap.  
In the context of this task, we look at functions for **lsof** — for usage examples, see [this file](psutil_lsof.md), which describes equivalents for these lsof functions:  
1) lsof -p <pid>  
2) lsof -i  
3) lsof -p <pid> | grep mem  
4) lsof +d  

#### Strace detailed description
Tracing configuration:
1. `-e trace=` : Allows selecting which system call types to trace. For example:
   - `-trace=open` : trace only file open calls
   - `-trace=write` : trace only file write calls
   - `-trace=all` : trace all system calls

2. `-o filename` : Write trace output to the specified file

Main flags:
1) **-p PID** – attach to a running process by its PID
2) **-c** – print syscall usage statistics after the program finishes
3) **-f** – trace child processes
4) **-s <size bytes>** – limit length of printed output for each syscall

With **strace**, you can trace ram, rom, cpu, net:
1) `strace -c ./program` – syscall trace (cpu)
2) `strace -v -r -T ./program` – ram tracing – flags -v -r -T configure output:  
   a) -v prints additional syscall details (arguments, return values)  
   b) -r shows time spent per syscall in relative format  
   c) -T adds timestamps since program start in microseconds
3) `strace -e trace=file,read,write` – pick what to trace — file access, reading, writing
4) `strace -e trace=network ./program` – generates output like: socket, connect, sendto, recv

#### Interesting programs
[python memory_profiler](https://github.com/pythonprofilers/memory_profiler)  
Output looks like: `Line # Mem usage Increment Occurrences Line Contents`
