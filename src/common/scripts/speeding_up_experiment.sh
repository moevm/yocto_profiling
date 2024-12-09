#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$(realpath $0)")
SRC_DIR=$SCRIPT_DIR/..
PROJECT_DIR=$SRC_DIR/..
BUILDSTATS_DIR=$SRC_DIR/yocto-build/assembly/build/tmp/buildstats
SAVE_DIR=$SRC_DIR/buildstats_saves
SAVING_TIME_FILE=$SAVE_DIR/time.txt

CONTAINER_NAME=yocto-container
IMAGE_NAME=yocto-image

function get_count_of_runs() {
  if [ -z "$1" ]; then
    echo "Enter number of times to build yocto image"
    exit 1
  fi

  num_runs=$1
}

function make_task_children_file() {
  ../entrypoint.sh clean-build
  ../entrypoint.sh clean-docker
  ../entrypoint.sh build-env --no-perf
  ../entrypoint.sh build-yocto --only-poky

  cd yocto-build
  docker compose run --rm --entrypoint /bin/sh $CONTAINER_NAME -c "source assembly/poky/oe-init-build-env assembly/build/ >/dev/null && bitbake -g core-image-minimal"

  cd $PROJECT_DIR
  python3 main.py -g task_children -d ./src/yocto-build/assembly/build/task-depends.dot
  cd $SRC_DIR
}

function prepare_build() {
  ../entrypoint.sh clean-docker
  ../entrypoint.sh clean-build
  ../entrypoint.sh build-env --no-perf
  cp dep_graph/text-files/task-children.txt yocto-build/assembly
}

function create_saving_dir() {
  if [ -d $SAVE_DIR ]; then
    rm -rf $SAVE_DIR
  fi

  mkdir $SAVE_DIR
  echo "" > $SAVING_TIME_FILE
}

function setup_patches () {
	if [[ "$PATCHES_ARG" -eq 0 ]]; then
    return 0
  fi
	patches_count=${#CUSTOM_PATCHES_ARR[@]}
	if [[ "$patches_count" -eq 0 ]]; then
		for((i=0; i < ${#ALL_PATCHES_ARR[@]}; i++)); do
			../entrypoint.sh patch "${ALL_PATCHES_ARR[i]}"
		done
		return 0
	fi
	for ((i=0; i<patches_count; i++)); do
		../entrypoint.sh patch "${CUSTOM_PATCHES_ARR[i]}"
	done
}

function main() {
  ARGS=("$@")
  args_length=${#ARGS[@]}
  PATCHES_ARG=0
  CUSTOM_PATCHES_ARR=()
  ALL_PATCHES_ARR=("add_net_limit.patch" "add_net_buildstats.patch" "add_task_children_to_weight.patch")

  for((i=0; i < args_length; i++)); do
    if [[ "${ARGS[i]}" == "--patches" || "${ARGS[i]}" == "-p" ]]; then
      PATCHES_ARG=1
    fi
    if [[ "${ARGS[i]}" == *".patch"*  ]]; then
      CUSTOM_PATCHES_ARR+=("${ARGS[i]}")
    fi
  done

  cd $SRC_DIR
  get_count_of_runs ${ARGS[0]}
  create_saving_dir
  make_task_children_file
  prepare_build

  total_time=0
  for ((i=1; i<=num_runs; i++)); do
    ../entrypoint.sh clean-build
    ../entrypoint.sh build_yocto_image --only-poky
    setup_patches


    start_time=$(date +%s)
    ../entrypoint.sh build-yocto
    end_time=$(date +%s)

    elapsed_time=$((end_time - start_time))
    echo -e "run $i: $elapsed_time\n" >> $SAVING_TIME_FILE
    total_time=$((total_time + elapsed_time))

    cp -r $BUILDSTATS_DIR "$SAVE_DIR/run_$i"
  done

  ../entrypoint.sh clean-build

  average_time=$((total_time / num_runs))
  echo -e "average time: $average_time\n" >> $SAVING_TIME_FILE
}


main $@
