#! /bin/bash

function check_dirs(){
        DIRS=$1
        PATH_TO_DIRS=$2
	
        for dir in ${DIRS[*]}
        do
                if [[ ! -d $PATH_TO_DIRS/$dir ]]; then
                        echo -e "No such dir $dir."
                        echo -e "Errors with dirs were found. Check dirs by path: $PATH_TO_DIRS."
                        exit 1
                fi
        done
        echo -e "Required dirs were found by path $PATH_TO_DIRS."
}


function check_logs(){
	echo -e "STAGE: check logs"
	LOGS="$(docker logs -f -n 15 yocto_project)"
	RESULT_LOGS=$(echo $LOGS | grep -E "failed")

	if [[ ! -z "$RESULT_LOGS" ]]; then
        	echo -e "Errors were found."
        	exit 1
	fi
}

BASE_DIR=$PWD/../../src
SCRIPTS_DIR=$BASE_DIR/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks
DOCKERFILE_DIR=$BASE_DIR/yocto-build

echo -e "STAGE: check image"
$CHECKS_DIR/yocto-image-check.sh
if [ $? -eq 1 ]; then
        echo -e "\nVerification failed! Image wasn't found."
        exit 1
fi

echo -e "STAGE: choose check time"
CHECK_TIMES=(15 30 60)
SIZE=${#CHECK_TIMES[@]}
INDEX=$(($RANDOM % $SIZE))

echo -e "STAGE: start container"
cd $DOCKERFILE_DIR
docker compose up -d
echo -e "STAGE: start build yocto"

sleep ${CHECK_TIMES[$INDEX]}
echo -e "STAGE: stop container"
docker compose stop

echo -e "STAGE: check dirs"
BUILD_DIR=$BASE_DIR/yocto-build/assembly
RESULT_DIRS=(build_yocto logs poky scripts)
check_dirs $RESULT_DIRS $BUILD_DIR


BUILD_DIR=$BUILD_DIR/build_yocto
RESULT_BUILD_DIRS=(cache conf downloads sstate-cache tmp)
check_dirs $RESULT_BUILD_DIRS $BUILD_DIR

check_logs

echo -e "STAGE: reboot building"
docker compose up -d 

sleep 15
echo -e "STAGE: stop container"
docker compose stop

check_logs

echo -e "\nSUCCESS: test is passed."

