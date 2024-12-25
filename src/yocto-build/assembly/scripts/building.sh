#! /bin/bash


FRAGMENT_PATH=$POKY_DIR/meta/recipes-kernel/linux
YOCTO_REPOSITORY=https://github.com/yoctoproject/poky.git

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

  echo "Set proxy settings for git"
  git config --global http.proxy http://10.136.2.7:3128
  git config --global https.proxy http://10.136.2.7:3128

  if [ ! -d "./original_poky" ]; then
    echo "Clone Poky."
    git clone $YOCTO_REPOSITORY ./original_poky
    YOCTO_CLONING_CODE=$?

    if [ $YOCTO_CLONING_CODE -ne 0 ]; then
      rm -rf ./original_poky/
      echo -e "Yocto cloning from git ends with code: $YOCTO_CLONING_CODE"
      exit $YOCTO_CLONING_CODE
    fi
  fi
  
  if [ ! -d "./poky" ]; then
    mkdir -p ./poky
    rsync -avu ./original_poky/ ./poky/ > /dev/null
    YOCTO_CLONING_CODE=$?

    if [ $YOCTO_CLONING_CODE -ne 0 ]; then
	    rm -rf ./poky/
	    echo -e "Yocto cloning from buff \"./yocto-build/assembly/original_poky/\" ends with code: $YOCTO_CLONING_CODE"
      exit $YOCTO_CLONING_CODE
    fi
  fi

  echo "Yocto cloning finish successfully."
  cd $POKY_DIR

  CURRENT_BRANCH=$(git branch --show-current)
  if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    echo "Switch the branch."
    git checkout $YOCTO_COMMIT_HASH -b $BRANCH_NAME
  fi

  if [[ "$STAGE_VAR" == "only-poky" ]]; then
    exit $YOCTO_CLONING_CODE
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
	if [ -f $ASSEMBLY_DIR/build/conf/bblayers.conf ]; then
		rm $ASSEMBLY_DIR/build/conf/bblayers.conf
	fi

	source $POKY_DIR/oe-init-build-env $ASSEMBLY_DIR/build/ >/dev/null
	if [[ "$STAGE_VAR" != "no-layers" ]]; then
		$SCRIPTS_DIR/add_layers.sh $POKY_DIR
		cp $YOCTO_INSTALL_PATH/conf/original.conf $YOCTO_INSTALL_PATH/conf/local.conf
	fi

  if [ -f "$ASSEMBLY_DIR/task-children.txt" ]; then
    cp "$ASSEMBLY_DIR/task-children.txt" "$ASSEMBLY_DIR/build/task-children.txt"
  fi
        
	cp $YOCTO_INSTALL_PATH/conf/local.conf $ASSEMBLY_DIR/build/conf/local.conf

	mkdir -p $FRAGMENT_PATH/files/
	cp $YOCTO_INSTALL_PATH/conf/fragment.cfg $FRAGMENT_PATH/files/fragment.cfg
	$SCRIPTS_DIR/update_kernel.sh $FRAGMENT_PATH
 
	bitbake-layers show-layers
	bitbake core-image-minimal
	YOCTO_EXIT_CODE=$?
	
	if [ $YOCTO_EXIT_CODE -ne 0 ]; then
	  echo "Yocto building ends with code: $YOCTO_EXIT_CODE"
          exit $YOCTO_EXIT_CODE
        fi
}

check_dirs
decorate_logs build
