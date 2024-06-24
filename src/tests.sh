#! /bin/bash

DOCKERFILE_DIR=$PWD/yocto-build
PATH_TO_CACHE=/yocto-build/assembly/build/sstate-cache


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
	python3 $DOCKERFILE_DIR/assembly/main.py start --path $PATH_TO_CACHE -p $1 -c $2

	EXIT_CODE=$?
	if [[ ! $EXIT_CODE -eq 0 ]]; then
		echo -e "\nError during upping sstate-cache servers."
		exit 1
	fi
}

function pipeline(){
        echo -e "\n\nSTAGE 1: build env\n\n"
        build_env

        echo -e "\n\nSTAGE 2: build yocto\n\n"
        build_yocto_image

        echo -e "\n\nSTAGE 3: start sstate-cache servers\n\n"
        start_servers $1 $2
}

function help(){
	echo -e "HELP:"
	echo -e "\t<start> - starts full pipeline"
	echo -e "\t\t<port> - optional arg, start port for servers"
	echo -e "\t\t<count> - optional arg, count of servers"
	echo -e "\t<kill> - stops and remove all containers with cache"
}


if [ $# -eq 0 ]; then
        help
        exit 0
fi

case "$1" in
	"start")
		echo -e "RUNNING FULL PIPELINE!"
		PORT=9000
       		COUNT_OF_SERVERS=4
		
		if [ ! -z "$2" ]; then
			result=$(echo $2 | grep -E '^[[:digit:]]+$')
			if [[ ! -z "$result" && "$result" -gt "8000" ]]; then
				PORT=$result
			fi
		fi

		if [ ! -z "$3" ]; then
                        result=$(echo $3 | grep -E '^[[:digit:]]+$')
                        if [[ ! -z "$result" && "$result" -ge "2" ]]; then
                                COUNT_OF_SERVERS=$result
			fi
                fi

		echo -e "\nARGS: START_PORT=$PORT COUNT_OF_SERVERS=$COUNT_OF_SERVERS"
		pipeline $PORT $COUNT_OF_SERVERS
		;;
	"kill")
		echo -e "STOP AND REMOVE CACHE CONTAINERS!"
		python3 $DOCKERFILE_DIR/assembly/main.py kill --path $PATH_TO_CACHE
		;;
	*)
		help
		;;
esac

