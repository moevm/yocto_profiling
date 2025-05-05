#!/bin/bash

#set -e

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
USE_PATCH=$2


function get_count_of_runs() {
  if [ -z "$1" ]; then
    echo "Enter number of times to build yocto image"
    exit 1
  fi

  num_runs=$1
}

function make_task_children_file() {
  #$ENTRYPOINT_DIR/entrypoint.sh clean-build --orig
  #$ENTRYPOINT_DIR/entrypoint.sh clean-docker
  #$ENTRYPOINT_DIR/entrypoint.sh build-env --no-perf
  #$ENTRYPOINT_DIR/entrypoint.sh build-yocto --only-poky
  #cd $DOCKERFILE_DIR
  #docker compose run --rm --entrypoint /bin/sh $CONTAINER_NAME -c "source assembly/poky/oe-init-build-env assembly/build/ >/dev/null && bitbake -g core-image-minimal"
  #cd - > /dev/null
  #python3 $ANALYSIS_DIR/main.py -g task_children -d $ASSEMBLY_DIR/build/task-depends.dot
  echo "Doing chidlerens (skipped)"
}

function prepare_build() {
  #$ENTRYPOINT_DIR/entrypoint.sh clean-docker
  $ENTRYPOINT_DIR/entrypoint.sh clean-build
  #$ENTRYPOINT_DIR/entrypoint.sh build-env --no-perf
  #cp $ANALYSIS_DIR/dep_graph/text-files/task-children.txt $ASSEMBLY_DIR
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

  get_count_of_runs ${ARGS[0]}
  create_saving_dir
  make_task_children_file
  prepare_build

  total_time=0
  for ((i=1; i<=num_runs; i++)); do

    $ENTRYPOINT_DIR/entrypoint.sh clean-build
    $ENTRYPOINT_DIR/entrypoint.sh build-yocto --only-poky
    #$ENTRYPOINT_DIR/entrypoint.sh patch add_task_children_to_weight.patch
    #$ENTRYPOINT_DIR/entrypoint.sh patch new-weights.patch
    #$ENTRYPOINT_DIR/entrypoint.sh patch weigth-with-limit.patch
    $ENTRYPOINT_DIR/entrypoint.sh patch limit_subthread.patch
    if [ ! -z "$USE_PATCH" ]; then
	    echo "Using patches"
	    $ENTRYPOINT_DIR/entrypoint.sh patch limit_subthread.patch
    else
	    echo "no patches"
    fi
    #exit 2

    mkdir -p $ASSEMBLY_DIR/build
    cp $ASSEMBLY_DIR/new-sched.txt $ASSEMBLY_DIR/build/new-sched.txt

    sync
    start_time=$(date +%s)
    $ENTRYPOINT_DIR/entrypoint.sh build-yocto --no-layers
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
