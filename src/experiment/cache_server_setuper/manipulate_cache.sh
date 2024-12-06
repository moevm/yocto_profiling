#! /bin/bash

SCRIPT_DIR=$(dirname "$(realpath $0)")
SRC_DIR=$SCRIPT_DIR/../..
DOCKERFILE_DIR=$SRC_DIR/yocto-build
PATH_TO_CACHE=$SRC_DIR/yocto-build/assembly/build/sstate-cache

function start_servers(){
	python3 $SCRIPT_DIR/cache.py start --path $PATH_TO_CACHE -p $1 -c $2

	EXIT_CODE=$?
	if [[ ! $EXIT_CODE -eq 0 ]]; then
		echo -e "\nError during upping sstate-cache servers."
		exit 1
	fi
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
		echo -e "\n\nStart sstate-cache servers: \n\n"
    start_servers $PORT $COUNT_OF_SERVERS
		;;
	"kill")
		echo -e "STOP AND REMOVE CACHE CONTAINERS!"
		python3 $SCRIPT_DIR/cache.py kill --path $PATH_TO_CACHE
		;;
	*)
		help
		;;
esac

