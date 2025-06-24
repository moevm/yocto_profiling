#! /bin/bash

ENTRYPOINT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
if [ -z $ENTRYPOINT_DIR ] || [ "os_profiling" != $(basename -s .git `git config --get remote.origin.url`) ]; then
  echo -e "You are not in the os_profiling cloned repo!"
  exit 2
fi
. $ENTRYPOINT_DIR/src/common/scripts/vars.sh
CURRENT_DIR=$(dirname "$(realpath $0)")


function help() {
  echo "Usage: entrypoint [ env | build-env ]
                    --no-perf -- disables installation of the perf
                    --no-cache -- disables docker cache using

                  *required stage build-env*
                  [ sh | shell ]
                  [ by | build-yocto ]
                      --only-poky -- only clones poky repo
                      --no-layers -- build yocto image without layers and dependencies
                      --tracing <tool> -- enables tracing of the build with one of the tools (perf, ftrace, strace)
                      --conf-file <path> -- config file to use (works only for --no-layers)

                  *required cloned poky*
                  [ p | patch ] <list_of_patches>
                      -r, --reverse -- disable choosen patches
                      -l, --patches-list -- print available patches

                  *required built yocto*
                  [ sy | start-yocto ]

                  [ cd | clean-docker ]
                  [ cb | clean-build ]
                      -o, --orig -- also cleans original poky dir
                  [ deps | install-deps ]
                  [ check ]"

  exit 2
}

function docker_check() {
	$CHECKS_DIR/docker-check.sh
	EXIT_CODE=$?
  if [[ ! $EXIT_CODE -eq 0 ]]; then
    echo -e "\nVerification failed! Problems were found."
    exit $EXIT_CODE
  fi

	echo -e "\nVerification completed successfully!"
  exit 0
}

function build_env_stage() {
  REQS_ARG="perf"
  NO_CACHE=""

  while :
  do
    case "$1" in
      --no-perf )
        echo "DISABLE PERF"
        REQS_ARG="requirements"
        shift 1
        ;;
      --no-cache )
        echo "DISABLE CACHING"
        NO_CACHE="--no-cache"
        shift 1
        ;;
      --)
        break
        ;;
      *)
        echo "Unexpected option for command \`build-env\`: $1"
        exit 2
        ;;
    esac
  done

  echo "BUILDING ENV"
  $SCRIPTS_DIR/build-env.sh $DOCKERFILE_DIR $REQS_ARG $NO_CACHE
  EXIT_CODE=$?
}

function build_yocto_stage() {
  TTOOL="none"
  STAGE_ARG="full"
  CONFIG_FILE=$CONFIGS_DIR/default.conf

  while :
  do
    case "$1" in
      --only-poky )
        echo "CLONING POKY REPO ONLY"
        STAGE_ARG="only-poky"
        shift 1
        ;;
      --no-layers )
        echo "ENABLE no-layers MODE"
        STAGE_ARG="no-layers"
        shift 1
        ;;
      --conf-file )
        CONFIG_FILE="$2"
        if [ ! -s "$CONFIG_FILE" ]; then
           echo -e "$CONFIG_FILE does not exist, or is empty!"
           exit 2
        fi
        echo "USING CONF $CONFIG_FILE"
        shift 2
        ;;
      --tracing )
        check_ttool $2
        TTOOL="$2"
        shift 2
        ;;
      -- )
        break
        ;;
      * )
        echo "Unexpected option for command \`build-yocto\`: $1"
        exit 2
        ;;
    esac
  done
  cp $CONFIG_FILE $CONFIGS_DIR/local.conf
  
  echo ""
  $SCRIPTS_DIR/build-yocto.sh $DOCKERFILE_DIR $CHECKS_DIR $CONTAINER_NAME $IMAGE_NAME $STAGE_ARG $TTOOL
  EXIT_CODE=$?
}

function check_ttool() {
  LIST="strace ftrace perf"
  VALUE=$1
  IS_VALUE_IN_LIST=$(echo $LIST | tr " " "\n" | grep -F -x "$VALUE")
  if [ -z $IS_VALUE_IN_LIST ]; then
    echo "Unexpected tracing tool: $1"
    exit 2
  fi
}

function clean_docker() {
  CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME 2> /dev/null)
  if [[ "$CONTAINER_ID" =~ ^[[:xdigit:]]+$ ]]; then
    docker rm -f $CONTAINER_ID
  fi

  $CHECKS_DIR/yocto-image-check.sh $IMAGE_NAME
  CHECK_CODE=$?
  if [ $CHECK_CODE -eq 0 ]; then
    IMAGE_ID=$(docker inspect --format="{{.Id}}" $IMAGE_NAME)
    docker rmi $IMAGE_ID
  fi

  EXIT_CODE=$?
}

function clean_build() {
  CLEANING_ORIG_POKY=0
  while :
  do
    case "$1" in
      -o | --orig )
        CLEANING_ORIG_POKY=1
        shift 1
        break
        ;;
      --)
        break
        ;;
      *)
        echo "Unexpected option for command \`clean-build\`: $1"
        exit 2
        ;;
    esac
  done

  echo "DELETING POKY, BUILD, LOCAL.CONF"
  rm -rf $ASSEMBLY_DIR/poky
  rm -rf $ASSEMBLY_DIR/build
  rm -f $CONFIGS_DIR/local.conf

  if [ $CLEANING_ORIG_POKY -eq 1 ]; then
    echo "DELETING ORIG POKY"
    rm -rf $ASSEMBLY_DIR/original_poky
  fi

  EXIT_CODE=$?
}

function install_analysis_deps() {
  deactivate 2> /dev/null
  cd $ENTRYPOINT_DIR && python3 -m venv venv

  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    MSYS_NT*)   MACHINE=MSys;;
    *)          MACHINE="UNKNOWN:${unameOut}"
  esac

  if [[ "$MACHINE" != "Linux" ]]; then
    echo -e "Machine: $MACHINE"
    echo -e "Activate venv and install dependencies from requirements.txt file"
    echo -e "Command for installing: pip3 install -r $ENTRYPOINT_DIR/requirements.txt"
    exit 0
  fi

  # Doesn't work for Windows systems (path = $ENTRYPOINT_DIR/venv/Scripts/activate)
  source $ENTRYPOINT_DIR/venv/bin/activate
  pip3 install -r $ENTRYPOINT_DIR/requirements.txt
}


# ===========================
if [ $# -eq 0 ]; then
	help
fi

COMMAND=$1
shift 1
VALID_ARGUMENTS=$#

case "$COMMAND" in
  env | build-env )
    build_env_stage $@ --
    ;;
  sh | shell )
    $SCRIPTS_DIR/shell.sh $DOCKERFILE_DIR $CHECKS_DIR $CONTAINER_NAME $IMAGE_NAME
    EXIT_CODE=$?
    ;;
  by | build-yocto )
    build_yocto_stage $@ --
    ;;
  p | patch )
		if [ $# -eq 0 ]; then
      echo "[WARNING]: No instructions were found"
      help
    fi

    $SCRIPTS_DIR/patching.sh $DOCKERFILE_DIR $CHECKS_DIR $CONTAINER_NAME $IMAGE_NAME $@
    EXIT_CODE=$?
    ;;
  sy | start-yocto )
    $SCRIPTS_DIR/start-yocto.sh $DOCKERFILE_DIR $CHECKS_DIR $CONTAINER_NAME $IMAGE_NAME
    EXIT_CODE=$?
    ;;
  cd | clean-docker )
    clean_docker
    ;;
  cb | clean-build )
    clean_build $@ --
    ;;
  deps | install-deps )
    install_analysis_deps
    ;;
  check )
    docker_check
    ;;
  st | selftest )
    $SCRIPTS_DIR/run_selftest.sh $DOCKERFILE_DIR $CONTAINER_NAME
    EXIT_CODE=$?
    ;;
  * )
    echo -e "[ERROR]: Unexpected command found <$COMMAND>!\n"
    help
		;;
esac

if [[ ! $EXIT_CODE -eq 0 ]]; then
	echo "Exit code: $EXIT_CODE"
	$CHECKS_DIR/active-container-check.sh $DOCKERFILE_DIR $CONTAINER_NAME
fi
# ===========================
