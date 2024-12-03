#! /bin/bash

DOCKERFILE_DIR=$1
CONTAINER_NAME=$2

GET_RUN_CONTAINER=$(docker ps --format '{{.Names}}' | grep -- "$CONTAINER_NAME")
if [[ ! -z $GET_RUN_CONTAINER ]]; then
	cd $DOCKERFILE_DIR
	docker compose stop
fi

