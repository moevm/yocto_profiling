# BitBake Load Pressure Variables

## BB_PRESSURE_MAX_CPU  
Defines the maximum CPU load threshold above which the BitBake scheduler will not start new tasks (if at least one task is already running). If unset, CPU load is not considered when starting tasks.

## BB_PRESSURE_MAX_IO  
Defines the maximum I/O load threshold above which the BitBake scheduler will not start new tasks (if at least one task is already running). If unset, I/O load is not considered.

## BB_PRESSURE_MAX_MEMORY  
Defines the maximum memory pressure threshold above which the BitBake scheduler will not start new tasks (if at least one task is already running). If unset, memory load is not considered.

Memory pressure occurs when time is spent swapping, reclaiming pages, or performing recovery. That’s why memory pressure is rarely observed, but setting this variable can be useful as a last resort to prevent OOM errors during builds.

### How BitBake Monitors Free Disk Space

The `BB_DISKMON_DIRS` variable lists directories whose free space should be monitored, along with minimum space thresholds (`minSpace`) and actions (`action`) to take when space is insufficient.

About every 10 seconds, BitBake uses `os.statvfs()` to check free space. If it drops below `minSpace`, it performs the specified `action`:
- `STOPTASKS` – stop starting new tasks and complete active ones
- `HALT` – immediately stop all tasks

## How Pressure Variables Are Evaluated

Each variable accepts values from 1 (min) to 1,000,000 (max).  
- If a value is below the minimum, the build stops immediately.
- If it exceeds the max, it’s ignored.

Current pressure values are read from:
- `/proc/pressure/cpu`
- `/proc/pressure/io`
- `/proc/pressure/memory`

BitBake saves pressure values (`prev_cpu_pressure`, etc.) at least once per second.  
Each time a new task is considered, it checks the latest pressure values.  
If any exceed the max thresholds, BitBake continues running active tasks but pauses new ones until pressure falls below the limits.
