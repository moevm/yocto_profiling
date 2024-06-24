#! /bin/bash


CHECKS_DIR=$(dirname "$0")/checks
IMAGE_CHECK=yocto-image-check.sh

$CHECKS_DIR/$IMAGE_CHECK
if [[ $? -eq 1 ]]; then
	exit 1
fi

cd $1


if [[ "$2" == "clone_poky" ]]; then
	STAGE_VAR="$2" docker compose up
elif [[ "$2" == "full" ]]; then
	docker compose up
else
	echo -e "Wrong stage arg!"
	exit 1
fi

CONTAINER_NAME=yocto_project
CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)

EXIT_CODE=$(docker inspect $CONTAINER_ID --format='{{.State.ExitCode}}')
exit $EXIT_CODE
