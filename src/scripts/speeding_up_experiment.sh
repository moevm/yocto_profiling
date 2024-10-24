#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$(realpath $0)")
SRC_DIR=$SCRIPT_DIR/..
PROJECT_DIR=$SRC_DIR/..
BUILDSTATS_DIR=$SRC_DIR/yocto-build/assembly/build/tmp/buildstats
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
  ./entrypoint.sh clean-build
  ./entrypoint.sh clean-docker
  ./entrypoint.sh build_env --no-perf
  ./entrypoint.sh build_yocto_image --only-poky
  ./entrypoint.sh patch runqueue.patch
  ./entrypoint.sh build_yocto_image

  cd yocto-build
  docker compose up -d
  docker exec -it yocto_project sh -c "source assembly/poky/oe-init-build-env assembly/build/ >/dev/null && bitbake -g core-image-minimal"
  docker compose stop

  cd $SRC_DIR

  cp yocto-build/assembly/queue yocto-build/assembly/build
  cp yocto-build/assembly/skip yocto-build/assembly/build

  cd $PROJECT_DIR
  python3 main.py -g graph -b 0 -p ./src/yocto-build/assembly/ -d ./src/yocto-build/assembly/build/task-depends.dot
  cd $SRC_DIR
}

function prepare_build() {
  ./entrypoint.sh clean-docker
  ./entrypoint.sh clean-build
  ./entrypoint.sh build_env --no-perf
  cp dep_graph/text-files/task-children.txt yocto-build/assembly
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

  cd $SRC_DIR
  get_count_of_runs ${ARGS[0]}
  create_saving_dir
  make_task_children_file
  prepare_build



  total_time=0
  for ((i=1; i<=num_runs; i++)); do
    ./entrypoint.sh clean-build
    ./entrypoint.sh build_yocto_image --only-poky
    ./entrypoint.sh patch add_net_limit.patch add_net_buildstats.patch add_task_children_to_weight.patch


    start_time=$(date +%s)
    ./entrypoint.sh build_yocto_image
    end_time=$(date +%s)

    elapsed_time=$((end_time - start_time))
    echo -e "run $i: $elapsed_time\n" >> $SAVING_TIME_FILE
    total_time=$((total_time + elapsed_time))



    cp -r $BUILDSTATS_DIR "$SAVE_DIR/run_$i"
  done

  ./entrypoint.sh clean-build

  average_time=$((total_time / num_runs))
  echo -e "average time: $average_time\n" >> $SAVING_TIME_FILE
}


main $@