#! /bin/bash

SCRIPTS_DIR=$PWD/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks

DOCKERFILE_DIR=$PWD/yocto-build

function help() {
        echo "This script is needed for interaction with the image of Yocto Project."
        echo "List of available parameters:"

        echo -e "\t<build_env> -- builds an image of the virtual environment."
	echo -e "\t\t<--no-perf> -- disables installation of the perf."

	echo -e "\t*ONLY AFTER STAGE*: build_env"
        echo -e "\t<shell> -- opens a terminal in container."
        echo -e "\t<build_yocto_image> -- build the yocto image in container."
	echo -e "\t\t<--only-poky> -- only clones poky instead of a full build."

	echo -e "\t*ONLY AFTER STAGE*: build_yocto_image"
	echo -e "\t<start_yocto> -- up the yocto image."
	echo -e ""

	echo "Verify that dependencies are installed for the project:"
	echo -e "\t<check> -- check of all dependencies."
}

function check(){
	check_codes=()

	$CHECKS_DIR/docker-check.sh
	check_codes+=($?)
	for code in ${check_codes[@]}; do
		if [ $code -eq 1 ]; then
			echo -e "\nVerification failed! Problems were found."
			exit 1
		fi
	done
	echo -e "\nVerification completed successfully!"
}

if [ $# -eq 0 ]; then
	help
	exit 0
fi

EXIT_CODE=0
case "$1" in 
	"build_env")
		REQS_ARG="perf"
	        if [[ ! -z "$2" ]]; then
        	        if [[ "$2" == "--no-perf" ]]; then
                	        REQS_ARG="requirements"
                	fi
        	fi

		$SCRIPTS_DIR/build_env.sh $DOCKERFILE_DIR $REQS_ARG
		;;
	"shell")
		$SCRIPTS_DIR/shell.sh $DOCKERFILE_DIR
		
		EXIT_CODE=$?
		;;
	"build_yocto_image")
		STAGE_ARG="full"
                if [[ ! -z "$2" ]]; then
                        if [[ "$2" == "--only-poky" ]]; then
                                STAGE_ARG="clone_poky"
                        fi
                fi

		$SCRIPTS_DIR/build_yocto_image.sh $DOCKERFILE_DIR $STAGE_ARG
		
		EXIT_CODE=$?
		;;
	"start_yocto")
		$SCRIPTS_DIR/start_yocto.sh $DOCKERFILE_DIR
		
		EXIT_CODE=$?
		;;
	"check")
		check
		;;
	*)
		echo -e "Unexpected parameter found <$1>!\n"
        	help
        	exit 1
		;;
esac


if [[ ! $EXIT_CODE -eq 0 ]]; then
	echo "Exit code: $EXIT_CODE"
	$CHECKS_DIR/active-container-check.sh
fi

