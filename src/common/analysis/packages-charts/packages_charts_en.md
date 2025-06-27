# Mapping Resource Usage to Packages

## Available Data

To map resource usage to specific packages, log files located in the `build/tmp/buildstats/<timestamp>/` directory were analyzed. This directory contains subdirectories for each package involved in the build process. Each subdirectory includes log files such as `do_configure`, `do_install`, `do_compile`, etc. The log format is described in `yocto_buildstats.md`:  
[yocto_buildstats.md](https://github.com/moevm/os_profiling/blob/denisova_olga_yocto_buildstats/wiki/yocto_buildstats.md)

From these logs, we can extract the following characteristics:

1. **Elapsed time** – total time taken  
2. **utime** – user mode time  
3. **stime** – system (kernel) mode time  
4. **cutime** – user mode time of child processes  
5. **cstime** – system mode time of child processes  
6. **IO rchar** – bytes read from storage  
7. **IO read_bytes** – estimated number of bytes read from storage (accurate for block-based file systems)  
8. **IO wchar** – bytes written to disk  
9. **IO write_bytes** – estimated bytes written to storage  
10. **IO cancelled_write_bytes** – bytes written that were canceled due to page cache truncation  
11. **IO syscr** – estimated number of read I/O operations  
12. **IO syscw** – estimated number of write I/O operations  
13. **rusage ru_utime** – user CPU time in seconds  
14. **rusage ru_stime** – system CPU time in seconds  
15. **rusage ru_maxrss** – peak resident set size in KB  
16. **rusage ru_minflt** – number of minor page faults (handled without disk I/O)  
17. **rusage ru_majflt** – number of major page faults (required disk I/O)  
18. **rusage ru_inblock** – block input operations  
19. **rusage ru_oublock** – block output operations  
20. **rusage ru_nvcsw** – voluntary context switches  
21. **rusage ru_nivcsw** – involuntary context switches  
22. **Child rusage ru_utime** – same as (2), but for all child processes  
23. **Child rusage ru_stime** – same as (3), for all child processes  
24. **Child rusage ru_maxrss** – same as (15), for all child processes  
25. **Child rusage ru_minflt** – same as (16), for all child processes  
26. **Child rusage ru_majflt** – same as (17), for all child processes  
27. **Child rusage ru_inblock** – same as (18), for all child processes  
28. **Child rusage ru_oublock** – same as (19), for all child processes  
29. **Child rusage ru_nvcsw** – same as (20), for all child processes  
30. **Child rusage ru_nivcsw** – same as (21), for all child processes  

---

## Generating Resource Usage Charts

A Python script was created to generate visual charts showing resource usage per package. The most insightful metrics are:

- `utime`, `stime`, `cutime`, `cstime`  
- `IO rchar`, `IO wchar`  
- `rusage ru_utime`, `rusage ru_stime`, `rusage ru_maxrss`  
- `Child rusage ru_utime`, `Child rusage ru_stime`

Each metric is visualized as a separate graph and saved as a PNG image.

Example chart:  
![rusage ru_utime](https://github.com/moevm/os_profiling/assets/90854310/1d37013a-f817-43a9-876c-f306813b2d12)

All generated charts are located in the `charts/` directory.  
The code used to generate them is in the `make-charts.py` file.

---

## Mapping Resources to Processes

The directory `build/tmp/work` contains working subdirectories related to a specific architecture. These subdirectories include data about the packages. Each package directory contains a `temp/` folder with log files for each task (e.g., `log.do_<task>.pid`) and scripts used by BitBake (`run.do_<task>.pid`). These files are created and filled during the build.

All packages from `build/tmp/work` match those in `build/tmp/buildstats`, with the exception of `gcc-source-13.2.0-13.2.0`.  
The assumption is that using the PID in the filename, we can match specific resource metrics to the associated process.

This directory structure is described in the official documentation:  
[Yocto Project Reference Manual – Section 4.2.7.9](https://docs.yoctoproject.org/ref-manual/structure.html)
