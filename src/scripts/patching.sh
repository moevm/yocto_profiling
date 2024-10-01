#! /bin/bash

CHECKS_DIR=$(dirname "$0")/checks
IMAGE_CHECK=yocto-image-check.sh

$CHECKS_DIR/$IMAGE_CHECK
if [[ $? -eq 1 ]]; then
        exit 1
fi

cd $1
shift 1

STAGE_VAR="sleep" docker compose up -d
docker container exec -it yocto_project ./assembly/scripts/patching.sh $@

docker compose stop

