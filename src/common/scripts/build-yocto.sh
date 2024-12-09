#! /bin/bash


DOCKERFILE_DIR=$1
CHECKS_DIR=$2
CONTAINER_NAME=$3
IMAGE_NAME=$4
STAGE=$5
TRACING=$6
shift 6


$CHECKS_DIR/yocto-image-check.sh $IMAGE_NAME
if [[ $? -eq 1 ]]; then
	exit 1
fi

cd $DOCKERFILE_DIR
STAGE_VAR="$STAGE" IS_TRACING_NEEDED="$TRACING" docker compose up --no-log-prefix

CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)
EXIT_CODE=$(docker inspect $CONTAINER_ID --format='{{.State.ExitCode}}')

$CHECKS_DIR/active-container-check.sh $DOCKERFILE_DIR $CONTAINER_NAME
exit $EXIT_CODE
