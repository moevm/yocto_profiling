# What collects what information

## Found ready-made solutions

* Tracing using ftrace: [cpu_tracer](../yocto_profiling_tools/cpu_tracer.md)  
  - Collects information about process execution at the kernel level, traces events occurring in the system.  
  - Example of collected information:

    Script 1:
    ```text
    # tracer: function
    #
    # entries-in-buffer/entries-written: 410058/1739128   #P:8
    #
    #                                _-----=> irqs-off/BH-disabled
    #                               / _----=> need-resched
    #                              | / _---=> hardirq/softirq
    #                               / _--=> preempt-depth
    #                              | / _-=> migrate-disable
    #                              || /     delay
    #           TASK-PID     CPU#  |||  TIMESTAMP  FUNCTION
    #              | |         |   |||||     |         |
      pipewire-pulse-4336    [005] d..2.   496.209665: ep_poll_callback <-__wake_up_common
      pipewire-pulse-4336    [005] d..2.   496.209666: _raw_read_lock_irqsave <-ep_poll_callback
      pipewire-pulse-4336    [005] d..3.   496.209666: __rcu_read_lock <-ep_poll_callback
      pipewire-pulse-4336    [005] d..3.   496.209666: __rcu_read_unlock <-ep_poll_callback
      pipewire-pulse-4336    [005] d..3.   496.209666: __wake_up <-ep_poll_callback
      pipewire-pulse-4336    [005] d..3.   496.209666: __wake_up_common_lock <-__wake_up
    ```

    Script 2:
    ```text
    # tracer: function_graph
    #
    # CPU  DURATION                  FUNCTION CALLS
    # |     |   |                     |   |   |   |
     7)   0.283 us    |                } /* __update_load_avg_se */
     7)   0.273 us    |                __update_load_avg_cfs_rq();
     7)               |                update_cfs_group() {
     7)   0.268 us    |                  reweight_entity();
     7)   0.751 us    |                }
     7)   0.260 us    |                place_entity();
     7)   3.779 us    |              } /* enqueue_entity */
     7)   0.308 us    |              cpu_util();
     7)   0.264 us    |              hrtick_update();
     7) + 20.855 us   |            } /* enqueue_task_fair */
     7)               |            check_preempt_curr() {
     7)   0.290 us    |              resched_curr();
     7)   0.899 us    |            }
     7) + 32.511 us   |          } /* ttwu_do_activate */
     7)   0.269 us    |          _raw_spin_unlock();
     7) + 35.396 us   |        } /* sched_ttwu_pending */
     7) + 36.341 us   |      } /* __flush_smp_call_function_queue */
     7) + 36.903 us   |    } /* flush_smp_call_function_queue */
     7)               |    schedule_idle() {
     7)   0.411 us    |      rcu_note_context_switch();
     7)               |      raw_spin_rq_lock_nested() {
     7)   0.258 us    |        _raw_spin_lock();
     7)   0.773 us    |      }
     7)   0.275 us    |      update_rq_clock();
     7)               |      pick_next_task() {
     7)               |        pick_next_task_fair() {
     7)   0.258 us    |          put_prev_task_idle();
     ...
    ```

* Various profiling utilities: [profiling_tools](./profilling_tools.md)  
  - perf: collects system performance data.  
  - perf stat: collects performance statistics.  
  - perf mem: collects memory access information.  
  - iostat: collects input-output statistics.  
  - lsof: shows open files and sockets.  
  - strace: traces system calls.

* Process profiling using [psutil](./psutil_lsof.md):  
  - `psutil.Process.open_files()`: returns a list of open files for the specified process.  
  - `psutil.Process.connections()`: returns a list of all network connections for the specified process.  
  - `process.memory_maps()`: retrieves information about memory-mapped files for the specified process.

  - How it can be analyzed: analyzing the list of open files to identify potential bottlenecks and resource-intensive operations; counting the number of network connections to assess network load.

* Build statistics ([buildstats](../yocto_build/yocto_buildstats.md)):  
  - Collects:
    - Host system information [build_stats.txt](logs/build_stats.txt)
    - Average CPU load [cpu.log](logs/cpu.log)
    - Disk statistics [monitor_disk.log](logs/monitor_disk.log)
    - IO statistics [io.log](logs/io.log)
    - Memory usage info [memory.log](logs/memory.log)
    - Data about start/end/status of tasks (do_configure, do_install, do_compile, etc.)

  Example of a file with statistics for a single task – [do_fetch](logs/do_fetch.txt)  
  Example of a file with time series for a task – [do_fetch_timestamps](logs/do_fetch_timestamps.txt)

  - How it can be analyzed: average disk, IO, memory, CPU load can be calculated, as well as identification of the most resource-intensive tasks.

## Our developed solutions

* Ranking the most loaded tasks: [launch](../yocto_profiling_tools/launch.md)  
  - Collects information about the most resource-consuming tasks.

* Building and analyzing a dependency graph: [launch](../yocto_profiling_tools/launch.md)  
  - Collects:
    - Graph vertex sorting – [example file](logs/tasks-order.txt)
    - Offset between end of child vertex and start of parent vertex, with graph sorted by offset – [example file](logs/task-order-sorted-offset.txt)
    - Root detection
    - Tree structure check
    - Layered graph visualization

* Collecting IO and RAM information as time series: [buildstats_timestamps](https://github.com/moevm/os_profiling/blob/77b1476f8f5d8eb507c7887274aafdd615f64891/build/buildstats_timestamps/buildstats.patch)  
  - Example of collected information:
    ```
    Timestamp: 2024-06-25 17:45:13
    RAM: VmPeak: 147628 kB, VmSize: 147628 kB, VmHWM: 59252 kB, VmRSS: 59252 kB
    IO Stats: rchar: 576639, wchar: 47799, syscr: 53, syscw: 46, read_bytes: 0, write_bytes: 36864, cancelled_write_bytes: 0
    ```
  - How it can be analyzed: identify peaks, determine most loaded moments, visualize data for clarity.

* Recipe parsing time from different layers:  
  - Example result ([file](logs/layer_parsing_time.log)):
    ```
    meta: 113.22 seconds
    meta-poky: 0.03 seconds
    ```
  - How it can be analyzed: identify layers with the longest parsing time, and those with minimal parsing time.

* Parsing time of each recipe:  
  - Example result ([file](logs/recipe_parsing_time.log)):
    ```
    /home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
    ```
  - How it can be analyzed: identify the slowest and fastest-to-parse recipes.

* Mapping resource usage information to packages: [packages_charts](../../src/packages-charts/packages_charts.md)  
  - Collects information on how many resources were used by a specific package.  
  - How it can be analyzed: visualization (already implemented), identifying most resource-heavy packages for further optimization.

* Collecting download speed information (do_fetch): [netstats_instruction](https://github.com/moevm/os_profiling/blob/d8f3d754a654bb7150eaeac9e3c6942985120f1d/netstats_instruction.md)  
  - Example of collected data: `recieve_speed: 437265162.12 B\sec`.  
  - How it can be analyzed: identify low-speed download areas, optimize fetch times.
