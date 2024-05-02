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

docker compose up
EXIT_CODE=$?

if [[ ! $EXIT_CODE -eq 0 ]]; then
	echo -e "Problem was found."
	exit 1
fi

LOGS=$(docker logs -f -n 15 yocto_project)
RESULT=$(echo $LOGS | grep -E "Summary: There were *\d+ ERROR messages")

if [[ ! -z "$RESULT" ]]; then
	echo -e "Errors were found."
	exit 1
fi

echo -e "\nSUCCESS: test is passed."
