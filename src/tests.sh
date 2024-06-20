#! /bin/bash

DOCKERFILE_DIR=$PWD/yocto-build
PATH_TO_CACHE=/yocto-build/assembly/build_yocto/sstate-cache


command_list=("build_yocto" "create_servers" "build_yocto_image" "start_yocto")

function build_env(){
	./entrypoint.sh build_env --no-perf

	EXIT_CODE=$?
	if [[ ! $EXIT_CODE -eq 0 ]]; then
                echo -e "\nError during building env."
                exit 1
        fi
}

function build_yocto_image(){
	./entrypoint.sh build_yocto_image
	
	EXIT_CODE=$?
        if [[ ! $EXIT_CODE -eq 0 ]]; then
                echo -e "\nError during building yocto image."
                exit 1
        fi
}

function start_servers(){
	python3 $DOCKERFILE_DIR/assembly/main.py start --path $PATH_TO_CACHE

	EXIT_CODE=$?
        if [[ ! $EXIT_CODE -eq 0 ]]; then
                echo -e "\nError during upping sstate-cache servers."
                exit 1
        fi
}


if [ $# -eq 0 ]; then
        echo -e "Running full pipeline!"
	
	echo -e "\n\nSTAGE 1: build env\n\n"
	build_env

	echo -e "\n\nSTAGE 2: build yocto\n\n"
	build_yocto_image

	echo -e "\n\nSTAGE 3: start sstate-cache servers\n\n"
	start_servers

        exit 0
else
	if [[ "$1" == "kill" ]]; then
		python3 $DOCKERFILE_DIR/assembly/main.py kill --path $PATH_TO_CACHE
	fi
fi



