#! /bin/bash

BASE_DIR=$PWD/../../src
SCRIPTS_DIR=$BASE_DIR/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks
DOCKERFILE_DIR=$BASE_DIR/yocto-build


$CHECKS_DIR/yocto-image-check.sh
if [ $? -eq 1 ]; then
        echo -e "\nVerification failed! Image wasn't found."
        exit 1
fi

cd $DOCKERFILE_DIR

docker compose up -d
sleep 1
docker compose stop

docker logs -f -n 15 yocto_project
LOGS=$(docker logs -f -n 15 yocto_project)

echo -e "\nSUCCESS: test is passed."

