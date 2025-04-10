## Build Statistics Analysis

In the `/build/tmp/buildstats` directory, there are directories for each image with build status, located under a timestamp-named folder.

Inside it, there are subdirectories for each package included in the built image and a `build_stats` file containing:
 1. Host system information  
 2. Root filesystem location and size  
 3. Build timestamp  
 4. Average CPU load  
 5. Disk statistics

For example, one of my builds took 3535.9 seconds (~1 hour), with an average CPU load of 79.3%.

There are also files in the `buildstats` directory:
- `reduced_proc_meminfo.log`  
- `reduced_proc_diskstats.log`  
- `reduced_proc_stat.log`

These contain information about RAM, disk, and CPU usage, respectively.

These files follow the structure:
- Time 1  
- Metrics at time 1...

- Time 2  
- Metrics at time 2...

For example, `reduced_proc_meminfo.log` contains the following metrics: `MemTotal`, `MemFree`, `Buffers`, `Cached`, `SwapTotal`, `SwapFree`:

![image](https://github.com/moevm/os_profiling/assets/90854310/9af95970-91c4-416e-aa3c-9dde6f761781)

Also inside `buildstats`, there is a `reduced_proc_pressure` directory, which contains similar files about CPU Pressure, MEM Pressure, and I/O Pressure.

Inside the directories corresponding to packages, there are files named `do_configure`, `do_install`, `do_compile`, etc.  
They contain data on:
- Task start time  
- Task end time  
- Execution status  
- Other metadata (see example below)

![image](https://github.com/moevm/os_profiling/assets/90854310/29a233a1-ee12-4962-b441-c7fca2d38985)

---

## Filesystem Structure

A diagram was created to display the part of the project tree that contains the relevant statistics:  
![tmp_directory_structure](https://github.com/moevm/os_profiling/assets/90854310/19633b1b-3098-415f-97a4-8797da19caf7)

The diagram includes a legend explaining the variables used in the build system. More about these variables here:  
https://docs.yoctoproject.org/dev/ref-manual/variables.html#term-PV

---

## Mapping Packages from `buildstats` to `work`

From the diagram, we see that in `buildstats` packages include their PV and PR, but in `work` they do not.  
Therefore, mapping is done by progressively trimming characters from the end of the name in `buildstats` until a match is found in `work`.

---

## What Data Is Missing / Incomplete

Looking at the diagram, we see that both `buildstats` and `work` contain sets of packages.  
For almost every package in `buildstats`, PID data can be found in `work`, but **not for all**.

Additionally, the sets of task files sometimes don’t match.  
For example: in `buildstats`, a package `example` contains `do_compile` data (including resource usage),  
but in `work`, the corresponding `log.do_compile.PID` file is missing.  
This is why PID cannot always be determined for every task.

---

## Generating Build Charts

Using the script located at `/poky/scripts/pybootchartgui/pybootchartgui.py` and specifying the build timestamp,  
a build chart was generated (the command was run from the `build` directory):  
```bash
$ ../scripts/pybootchartgui/pybootchartgui.py tmp/buildstats/20240212085739/ -o ./
```

This generated `bootchart.png` in the `build` directory:

![bootchart](https://github.com/moevm/os_profiling/assets/90854310/59c9e50f-2349-42f9-a422-f4ed831fedf3)

---

## Build Chart Analysis

The X-axis on this chart represents build time in seconds.  
At the top are subgraphs showing:

1. CPU load  
2. Disk throughput  
3. Average CPU Pressure (a percentage ratio showing how often processes are paused waiting for CPU — calculated over 10, 60, and 300 seconds — data from `/proc/pressure/cpu`)  
4. Average I/O Pressure (same as above, but for input/output — from `/proc/pressure/io`)  
5. Average MEM Pressure (same idea, but for memory — from `/proc/pressure/memory`)  
6. Filesystem load (percentage of used/free memory)  
7. RAM load (including percentage taken by cache and buffers, and swap usage graph)

Then follows a time chart showing the execution of each task.  
For each task, you can see:
- When it started  
- When it ended  
- How many seconds it took  
- Task type is color-coded (configure/install/compile/etc.)

This chart helps visualize which tasks ran in parallel.
