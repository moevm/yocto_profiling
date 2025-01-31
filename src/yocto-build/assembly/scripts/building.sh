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

function prepare_for_build() {
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
}

function build() {
  LOG_FILE=$ASSEMBLY_DIR/logs/building_logs_$TRACING_TOOL.txt
  cp /dev/null $LOG_FILE
  image_name="core-image-minimal"

  case $TRACING_TOOL in
    perf )
      perf --version > /dev/null
      IS_PERF_INSTALLED=$?
      if [ $IS_PERF_INSTALLED -ne 0 ]; then
        echo -e "Perf is not installed."
        exit $IS_PERF_INSTALLED
      fi

      perf stat -a -o $LOG_FILE bitbake $image_name
      YOCTO_EXIT_CODE=$?
      ;;
    strace )
      strace -o $LOG_FILE bitbake $image_name
      YOCTO_EXIT_CODE=$?
      ;;
    ftrace )
      TRACING=/sys/kernel/debug/tracing
      sysctl kernel.ftrace_enabled=1

      echo function > ${TRACING}/current_tracer
      echo 1 > ${TRACING}/tracing_on

      bitbake $image_name
      YOCTO_EXIT_CODE=$?

      echo 0 > ${TRACING}/tracing_on
      ${dir}/trace >> $LOG_FILE
      ;;
    * )
      bitbake $image_name
      YOCTO_EXIT_CODE=$?
      ;;
  esac
}

check_dirs
prepare_for_build
build

if [ $YOCTO_EXIT_CODE -ne 0 ]; then
  echo "Yocto building ends with code: $YOCTO_EXIT_CODE"
  exit $YOCTO_EXIT_CODE
fi
