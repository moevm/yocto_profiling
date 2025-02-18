#!/bin/bash

set -e

ENTRYPOINT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
if [ -z $ENTRYPOINT_DIR ] || [ "os_profiling" != $(basename -s .git `git config --get remote.origin.url`) ]; then
  echo -e "You are not in the os_profiling cloned repo!"
  exit 2
fi
. $ENTRYPOINT_DIR/src/common/scripts/vars.sh
CURRENT_DIR=$(dirname "$(realpath $0)")

BUILDSTATS_DIR=$ASSEMBLY_DIR/build/tmp/buildstats
SAVE_DIR=$SRC_DIR/buildstats_saves
SAVING_TIME_FILE=$SAVE_DIR/time.txt


function get_count_of_runs() {
  if [ -z "$1" ]; then
    echo "Enter number of times to build yocto image"
    exit 1
  fi

  num_runs=$1
}

function make_task_children_file() {
  $ENTRYPOINT_DIR/entrypoint.sh clean-build --orig
  $ENTRYPOINT_DIR/entrypoint.sh clean-docker
  $ENTRYPOINT_DIR/entrypoint.sh build-env --no-perf
  $ENTRYPOINT_DIR/entrypoint.sh build-yocto --only-poky
  cd $DOCKERFILE_DIR
  docker compose run --rm --entrypoint /bin/sh $CONTAINER_NAME -c "source assembly/poky/oe-init-build-env assembly/build/ >/dev/null && bitbake -g core-image-minimal"
  cd - > /dev/null
  python3 $ANALYSIS_DIR/main.py -g task_children -d $ASSEMBLY_DIR/build/task-depends.dot
}

function prepare_build() {
  $ENTRYPOINT_DIR/entrypoint.sh clean-docker
  $ENTRYPOINT_DIR/entrypoint.sh clean-build
  $ENTRYPOINT_DIR/entrypoint.sh build-env --no-perf
  cp $ANALYSIS_DIR/dep_graph/text-files/task-children.txt $ASSEMBLY_DIR
}

function create_saving_dir() {
  if [ -d $SAVE_DIR ]; then
    rm -rf $SAVE_DIR
  fi

  mkdir $SAVE_DIR
  echo "" > $SAVING_TIME_FILE
}

function main() {
  ARGS=("$@")

  get_count_of_runs ${ARGS[0]}
  create_saving_dir
  make_task_children_file
  prepare_build

  total_time=0
  for ((i=1; i<=num_runs; i++)); do
    $ENTRYPOINT_DIR/entrypoint.sh clean-build
    $ENTRYPOINT_DIR/entrypoint.sh build-yocto --only-poky


    start_time=$(date +%s)
    $ENTRYPOINT_DIR/entrypoint.sh build-yocto
    end_time=$(date +%s)

    elapsed_time=$((end_time - start_time))
    echo -e "run $i: $elapsed_time\n" >> $SAVING_TIME_FILE
    total_time=$((total_time + elapsed_time))

    cp -r $BUILDSTATS_DIR "$SAVE_DIR/run_$i"
  done

  $ENTRYPOINT_DIR/entrypoint.sh clean-build

  average_time=$((total_time / num_runs))
  echo -e "average time: $average_time\n" >> $SAVING_TIME_FILE
}


main $@
