#! /bin/bash

DOCKERFILE_DIR=$1
CONTAINER_NAME=$2
shift 2

cd $DOCKERFILE_DIR
docker compose run --rm --entrypoint ./assembly/scripts/run_selftest.sh $CONTAINER_NAME $@


