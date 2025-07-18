# Guide for Processing Read/Write Log Statistics

1. To collect read/write statistics logs, run the build with the following command:
    ```bash
    strace -f -e trace=read,write,readv,writev -o yocto_trace_all.log bitbake core-image-minimal
    ```

2. You also need a file containing a list of tasks with their corresponding PIDs.  
   This can be obtained by running the task ranking as described in the [ranking instructions](../statistics_analyzer/README.md).  
   After completion, the file `ranking_output.txt` will be generated.

3. Next, process the logs using the `process_logs.py` script:
    ```bash
    python3 process_logs.py -l <path to yocto_trace_all.log> -t <path to ranking_output.txt>
    ```

4. After execution, two files will be created in the `read_write_statistics/output/` directory:
    - `process_statistics_rw.txt`: contains statistics for `read` and `write` operations  
    - `process_statistics_rwv.txt`: contains statistics for `readv` and `writev` operations
