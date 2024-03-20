#!/bin/sh

dir=/sys/kernel/debug/tracing

sysctl kernel.ftrace_enabled=1
echo function_graph > ${dir}/current_tracer
echo 1 > ${dir}/tracing_on 
sleep 1
echo 0 > ${dir}/tracing_on
echo $PWD/out.txt
less ${dir}/trace >> $PWD/out.txt