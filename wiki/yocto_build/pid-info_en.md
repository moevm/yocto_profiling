## PID Logging

PID logging happens when a function is executed via `bb.build._exec_task`:  
https://github.com/openembedded/bitbake/blob/master/lib/bb/build.py

When a function is launched as a task, in current BitBake versions,  
**PID is always logged.**

For types of functions/tasks BitBake supports and which can be run as tasks, see section 3.5:  
https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-metadata.html#functions

## Why Some Tasks Don’t Log PIDs

There’s no reason in BitBake source why a PID wouldn’t be logged.  
After analyzing tasks where PID is missing (~4 out of thousands),  
a pattern emerged: these tasks took ≈ 0.00 seconds and used almost no system resources.  
Most likely, PID file creation was skipped due to an internal exception.

PIDs are also logged in the shared `log.task_order` file for each package.  
This file is created earlier and always contains PIDs — making it a better source.

## Why Some Packages Lack PID Logs

Only `gcc-source` lacked log files in my tests.  
Yocto docs explain that `gcc` and related recipes use `/work-shared/`  
instead of the usual `/work/` directory:  
https://docs.yoctoproject.org/ref-manual/structure.html (Section 4.2.7.10)

The log output directory is defined by the `WORKDIR` BitBake variable.  
`WORKDIR` is defined in `bitbake.conf`, but for `gcc-source` it is overridden in  
`poky/meta/recipes-devtools/gcc/gcc-source.inc`.

As a result, `WORKDIR` points to `/work-shared/`, not `/work/`,  
so PIDs/logs should be expected there for `gcc-source`.
