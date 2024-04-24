#! /bin/bash

SCRIPTS_DIR=$PWD/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks
scripts_list=("build_env" "shell" "build_yocto_image" "start_yocto")

DOCKERFILE_DIR=$PWD/yocto-build

function help() {
        echo "This script is needed for interaction with the image of Yocto Project."
        echo "List of available parameters:"
        echo -e "\t<build_env> -- builds an image of the virtual environment."
        echo -e "\t<shell> -- opens a terminal in container."
        echo -e "\t<build_yocto_image> -- build the yocto image in container."
	echo -e "\t<start_yocto> -- up the yocto image.\n"

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


if [[ ${scripts_list[@]} =~ "$1" ]]; then
	$SCRIPTS_DIR/$1.sh $DOCKERFILE_DIR
	
	if [[ ! $? -eq 0 ]]; then
		echo "Exit code: $?"
		$CHECKS_DIR/active-container-check.sh
	fi

elif [[ $1 == "check" ]]; then
	check
else
	echo -e "Unexpected parameter found <$1>!\n"
        help
	exit 1
fi

