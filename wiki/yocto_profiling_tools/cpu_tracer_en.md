### CPU trace with ftrace

#### Script 1 – simple tracing
```Bash
#!/bin/sh

dir=/sys/kernel/debug/tracing

sysctl kernel.ftrace_enabled=1
echo function > ${dir}/current_tracer
echo 1 > ${dir}/tracing_on 
sleep 1
echo 0 > ${dir}/tracing_on
less ${dir}/trace

# to run this script
# chmod +x <name>
```

#### Script 2 – simple graph tracing
```Bash
#!/bin/sh

dir=/sys/kernel/debug/tracing

sysctl kernel.ftrace_enabled=1
echo function_graph > ${dir}/current_tracer
echo 1 > ${dir}/tracing_on 
sleep 1
echo 0 > ${dir}/tracing_on
less ${dir}/trace >> /home/oumuamua/yadro/test_prof/trace_grp.txt
```

Huge (titanic) logs are generated – 600,000 lines and 30+MB.

All scripts must be run with **sudo!**
