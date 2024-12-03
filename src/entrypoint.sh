#! /bin/bash

SRC_DIR=$(dirname "$(realpath $0)")
CONFIGS_DIR=$SRC_DIR/conf
PATCHES_DIR=$SRC_DIR/yocto-patches
DOCKERFILE_DIR=$SRC_DIR/yocto-build

POKY_DIR=$DOCKERFILE_DIR/assembly/poky

SCRIPTS_DIR=$SRC_DIR/common/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks

CONTAINER_NAME=yocto-container
IMAGE_NAME=yocto-image


function help() {
  echo "Usage: entrypoint [ env | build-env ]
                    --no-perf -- disables installation of the perf
                    --no-cache -- disables docker cache using

                  *required stage build-env*
                  [ sh | shell ]
                  [ by | build-yocto ]
                      --only-poky -- only clones poky repo
                      --no-layers -- build yocto image without layers and dependencies
                      --conf-file <path> -- config file to use (works only for --no-layers)

                  *required cloned poky*
                  [ p | patch ] <list_of_patches>
                      -r, --reverse -- disable choosen patches
                      -l, --patches-list -- print available patches

                  *required built yocto*
                  [ sy | start-yocto ]

                  [ cd | clean-docker ]
                  [ cb | clean-build ]
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
  STAGE_ARG="full"
  CONFIG_FILE=$CONFIGS_DIR/default.conf

  while :
  do
    case "$1" in
      --only-poky )
        echo "Only clones poky repo"
        STAGE_ARG="only-poky"
        break
        ;;
      --no-layers )
        echo "Enable no-layers mode"
        STAGE_ARG="no-layers"
        shift 1
        ;;
      --conf-file )
        CONFIG_FILE="$2"
        echo "Using conf $CONFIG_FILE"
        shift 2
        ;;
      --)
        break
        ;;
      *)
        echo "Unexpected option for command \`build-yocto\`: $1"
        exit 2
        ;;
    esac
  done
  cp $CONFIG_FILE $CONFIGS_DIR/local.conf

  $SCRIPTS_DIR/build-yocto.sh $DOCKERFILE_DIR $STAGE_ARG $CHECKS_DIR $CONTAINER_NAME $IMAGE_NAME
  EXIT_CODE=$?
}

function clean_docker() {
  CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME 2> /dev/null)
  if [ ! -z "${CONTCONTAINER_ID+x}" ]; then
    docker rm -f $CONTAINER_ID
  fi

  $CHECKS_DIR/yocto-image-check.sh $IMAGE_NAME
  CHECK_CODE=$?
  if [ $CHECK_CODE -eq 0 ]; then
    IMAGE_ID=$(docker inspect --format="{{.Id}}" $IMAGE_NAME)
    docker rmi $IMAGE_ID
  fi

  $SRC_DIR/entrypoint.sh build-env --no-perf --no-cache
  EXIT_CODE=$?
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
    echo "Remove poky, build dir, conf"
		rm -rf $DOCKERFILE_DIR/assembly/original_poky
		rm -rf $DOCKERFILE_DIR/assembly/poky
		rm -rf $DOCKERFILE_DIR/assembly/build
    rm -f $CONFIGS_DIR/local.conf
    ;;
  check )
    docker_check
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
