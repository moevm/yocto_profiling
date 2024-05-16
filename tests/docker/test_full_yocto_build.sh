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

cd $DOCKERFILE_DIR

echo "STAGE: start container"
docker compose up -d
EXIT_CODE=$?

echo "STAGE: check exit code"
if [[ ! $EXIT_CODE -eq 0 ]]; then
	echo -e "Problem was found."
	exit 1
fi

LOGS=$(docker logs -f -n 15 yocto_project)
RESULT_LOGS=$(echo $LOGS | grep -E "Summary: There were *\d+ ERROR messages")

echo "STAGE: check dirs"
BUILD_DIR=$BASE_DIR/yocto-build/assembly
RESULT_DIRS=(build_yocto logs poky scripts)
check_dirs $RESULT_DIRS $BUILD_DIR

BUILD_DIR=$BUILD_DIR/build_yocto
RESULT_BUILD_DIRS=(cache conf downloads sstate-cache tmp)
check_dirs $RESULT_BUILD_DIRS $BUILD_DIR

echo "STAGE: check files"
RESULT_BUILD_FILES=(bitbake.lock bitbake.sock hashserve.sock)
for file in ${RESULT_BUILD_FILES[*]}
do
        if [[ ! -e $BUILD_DIR/$file ]]; then
        	echo -e "No such file $file."
              	echo -e "Errors with files were found. Check files by path: $BUILD_DIR."
                exit 1
     	fi
done
echo -e "Required files were found."

echo "STAGE: check logs"
if [[ ! -z "$RESULT_LOGS" ]]; then
	echo -e "Errors were found."
	exit 1
fi

echo -e "\nSUCCESS: test is passed."
