#! /bin/bash


DOCKERFILE_DIR=$1
STAGE=$2
CHECKS_DIR=$3
CONTAINER_NAME=$4
IMAGE_NAME=$5


$CHECKS_DIR/yocto-image-check.sh $IMAGE_NAME
if [[ $? -eq 1 ]]; then
	exit 1
fi

cd $DOCKERFILE_DIR
STAGE_VAR="$STAGE" docker compose up

CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)
EXIT_CODE=$(docker inspect $CONTAINER_ID --format='{{.State.ExitCode}}')

$CHECKS_DIR/active-container-check.sh $DOCKERFILE_DIR $CONTAINER_NAME
exit $EXIT_CODE
