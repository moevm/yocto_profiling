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
STAGE_VAR="sleep" docker compose up -d
docker container exec -it $CONTAINER_NAME ./assembly/scripts/up_yocto.sh
$CHECKS_DIR/active-container-check.sh $DOCKERFILE_DIR $CONTAINER_NAME

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`
