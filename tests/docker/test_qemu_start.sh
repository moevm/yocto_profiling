#! /bin/bash


BASE_DIR=$PWD/../../src
DOCKERFILE_DIR=$BASE_DIR/yocto-build

echo -e "STAGE: start container"
cd $DOCKERFILE_DIR
STAGE_VAR="sleep" docker compose up -d

echo -e "STAGE: start yocto"
docker container exec -d yocto_project ./up_yocto.sh

sleep 15
echo -e "STAGE: stop container"
docker compose stop
EXIT_CODE=$?

echo -e "STAGE: check exit code"
if [[ $EXIT_CODE != 0 ]]; then
	echo -e "Errors was found."
	exit 1
fi

echo -e "\nSUCCESS: test is passed."
