#! /bin/bash


DOCKERFILE_DIR=$1
CHECKS_DIR=$2
CONTAINER_NAME=$3
IMAGE_NAME=$4

$CHECKS_DIR/yocto-image-check.sh $IMAGE_NAME
if [[ $? -eq 1 ]]; then
	exit 1
fi

cd $DOCKERFILE_DIR
docker compose run --rm -it --entrypoint /bin/bash $CONTAINER_NAME
