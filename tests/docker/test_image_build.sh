#! /bin/bash

BASE_DIR=$PWD/../../src
SCRIPTS_DIR=$BASE_DIR/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks

DOCKERFILE_DIR=$BASE_DIR/yocto-build
REQS_ARG="requirements"


$CHECKS_DIR/docker-check.sh
if [ $? -eq 1 ]; then
	echo -e "\nVerification failed! Check docker requirements."
        exit 1
fi
echo ""

$SCRIPTS_DIR/build_env.sh $DOCKERFILE_DIR $REQS_ARG 
if [ ! $? -eq 0 ]; then
        echo -e "\nVerification failed! Build was failed."
        exit 1
fi
echo ""

$CHECKS_DIR/yocto-image-check.sh
if [ $? -eq 1 ]; then
        echo -e "\nVerification failed! Image wasn't found."
        exit 1
fi

echo "SUCCESS: test is passed."
