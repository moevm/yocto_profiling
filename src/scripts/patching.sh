#! /bin/bash

CHECKS_DIR=$(dirname "$0")/checks
IMAGE_CHECK=yocto-image-check.sh

$CHECKS_DIR/$IMAGE_CHECK
if [[ $? -eq 1 ]]; then
        exit 1
fi

cd $1
shift 1

docker compose run --rm --entrypoint ./assembly/scripts/patching.sh yocto_project $@
