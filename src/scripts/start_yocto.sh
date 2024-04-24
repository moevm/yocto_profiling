#! /bin/bash


CHECKS_DIR=$(dirname "$0")/checks
IMAGE_CHECK=yocto-image-check.sh

$CHECKS_DIR/$IMAGE_CHECK
if [[ $? -eq 1 ]]; then
        exit 1
fi


cd $1

STAGE_VAR="stage_run" docker compose up -d
docker container exec -it yocto_project ./up_yocto.sh

docker compose stop

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`

