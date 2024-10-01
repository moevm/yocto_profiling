#! /bin/bash

ASSEMBLY_DIR=$YOCTO_INSTALL_PATH/assembly
POKY_DIR=$ASSEMBLY_DIR/poky
SCRIPTS_DIR=$ASSEMBLY_DIR/scripts
FRAGMENT_PATH=$POKY_DIR/meta/recipes-kernel/linux

HASH_TEMPLATE="^Checking sstate mirror object availability: 100% \|[#]*\| Time: [0-9]+:[0-5][0-9]:[0-5][0-9]$"
date=$(date +"%d-%m-%Y_%H:%M:%S")

BRANCH_NAME=my-upstream_5.0.1
YOCTO_REPOSITORY=git://git.yoctoproject.org/poky

YOCTO_EXIT_CODE=0
YOCTO_CLONING_CODE=0


function check_dirs() {
  cd $ASSEMBLY_DIR

  if [ ! -d "./logs" ]; then
    echo "Create log dir."
    mkdir logs
  fi

  check_poky
}

function check_poky() {

  if [ ! -d "./poky" ]; then
    echo "Clone Poky."
    git clone $YOCTO_REPOSITORY

    YOCTO_CLONING_CODE=$?
  fi

  if [ $YOCTO_CLONING_CODE -ne 0 ]; then
	  echo "Yocto cloning ends with code: $YOCTO_CLONING_CODE"
    exit $YOCTO_CLONING_CODE
  fi
  echo "Yocto cloning finish successfully."

  if [[ "$STAGE_VAR" == "only-poky" ]]; then
    exit $YOCTO_CLONING_CODE
  fi

  cd $POKY_DIR

  CURRENT_BRANCH=$(git branch --show-current)
  if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    echo "Switch the branch."
    git checkout $YOCTO_COMMIT_HASH -b $BRANCH_NAME
  fi

}

function start_logging() {
	# start utils for logging
	# $1 is txt file for logs
	# USE SUDO PLS 
	echo "Start building yocto:" >> $1
}

function finish_logging() {
	# finish utils for logging
	# $1 is txt file for logs
	# USE SUDO PLS
	echo "Completed building yocto!" >> $1
}

function decorate_logs() {
	LOG_FILE=$ASSEMBLY_DIR/logs/building_logs.txt

	if [ $# -eq 0 ]; then
		echo "You can use wrapper function. It takes any function with args and logs output to <./logs/building_logs.txt>"
		return 1
	fi

	FUNC_TO_LOG="$1"
	cp /dev/null $LOG_FILE

	start_logging $LOG_FILE
	$FUNC_TO_LOG $@ 2>&1
	finish_logging $LOG_FILE
}

function build() {
	source $POKY_DIR/oe-init-build-env $ASSEMBLY_DIR/build/ >/dev/null

  if [[ "$STAGE_VAR" != "no-layers" ]]; then
	  $SCRIPTS_DIR/add_layers.sh $POKY_DIR
	  cp $YOCTO_INSTALL_PATH/conf/local.conf $ASSEMBLY_DIR/build/conf/local.conf
  fi

	mkdir -p $FRAGMENT_PATH/files/
	cp $YOCTO_INSTALL_PATH/conf/fragment.cfg $FRAGMENT_PATH/files/fragment.cfg
	$SCRIPTS_DIR/update_kernel.sh $FRAGMENT_PATH
	
	bitbake-layers show-layers
	bitbake core-image-minimal | tee >( grep -E -i "$HASH_TEMPLATE" >$YOCTO_INSTALL_PATH/assembly/logs/filtered_logs_$date.txt)
	YOCTO_EXIT_CODE=$?

	if [ $YOCTO_EXIT_CODE -ne 0 ]; then
	  echo "Yocto building ends with code: $YOCTO_EXIT_CODE"
    exit $YOCTO_EXIT_CODE
  fi

  echo "Yocto cloning finish successfully."
}

check_dirs
decorate_logs build
