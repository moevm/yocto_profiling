#!/bin/bash

task_types="do_compile do_configure do_package do_install"
for ttype in $task_types; do
  for i in $(seq 2 6); do
    echo "Running $ttype, count $i"
    cp src/conf/default.conf.templ src/conf/default.conf
    echo "BB_MAX_TTYPE_COUNT = \"$ttype:$i\"" >> src/conf/default.conf
    ./src/common/scripts/speeding_up_experiment.sh 5 > no_dwnd_0105_${ttype}${i}.log
    cp -r ./src/buildstats_saves/ ./src/buildstats_saves_no_dwnd_0105_${ttype}${i}
  done
done
