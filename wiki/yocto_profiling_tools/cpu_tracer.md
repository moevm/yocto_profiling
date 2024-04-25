### CPU trace with ftrace
#### Скрипт 1 - простая трассировка 
```Bash
#!/bin/sh

dir=/sys/kernel/debug/tracing

sysctl kernel.ftrace_enabled=1
echo function > ${dir}/current_tracer
echo 1 > ${dir}/tracing_on 
sleep 1
echo 0 > ${dir}/tracing_on
less ${dir}/trace

# to run take this script all 
# chmod +x <name>
```

#### Скрипт 2 - простая трассировка в виде графа 
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

генерируются огромный (титанические) логи на 600.000 строк и 30+мб

Все скрипты запускаются под **sudo!**
