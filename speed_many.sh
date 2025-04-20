#!/bin/bash

# $1 -- new schedule
# $2 -- name for the dir
run_build() {
  cp $1 src/yocto-build/assembly/new-sched.txt
  ./src/common/scripts/speeding_up_experiment.sh > sexp_2004_$2.txt
  cp -r ./src/buildstats_saves/ ./src/buildstats_saves_$2
}

run_build new-sched-alns.txt alns
run_build new-sched-pjs-new.txt pjs_new
run_build new-sched-pjs-prev.txt pjs_prev
