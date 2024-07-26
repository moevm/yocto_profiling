#! /bin/bash

SCRIPTS_DIR=$PWD/scripts
CHECKS_DIR=$SCRIPTS_DIR/checks

DOCKERFILE_DIR=$PWD/yocto-build

function help() {
        echo "This script is needed for interaction with the image of Yocto Project."
        echo "List of available parameters:"

        echo -e "\t<build_env> -- builds an image of the virtual environment."
	echo -e "\t\t<--no-perf> -- disables installation of the perf."
	echo -e "\t\t<--no-cache> -- disables docker cache using."

	echo -e "\t*ONLY AFTER STAGE*: build_env"
        echo -e "\t<shell> -- opens a terminal in container."
        echo -e "\t<build_yocto_image> -- build the yocto image in container."
	echo -e "\t\t<--only-poky> -- only clones poky instead of a full build."

	echo -e "\t*ONLY AFTER STAGE*: build_yocto_image"
	echo -e "\t<start_yocto> -- up the yocto image."
	
	echo -e ""
	echo -e "\t<clean> -- removing existing container and image of yocto."
	echo -e "\t<del_volume> -- removing poky and build dir."

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

args_count=$#

EXIT_CODE=0
case "$1" in 
	"build_env")
		REQS_ARG="perf"
		NO_CACHE=""

		for (( i = 2; i <= $args_count; i++ ))
		do
			case "$2" in
				"--no-perf")
					echo "DISABLE PERF"
					REQS_ARG="requirements"
					;;
				"--no-cache")
					echo "DISABLE CACHING"
					NO_CACHE="--no-cache"
					;;
				*)
					echo "UNKNOWN ARG: $2"
					;;
			esac
			shift 1
		done
		echo "BUILDING ENV"
		$SCRIPTS_DIR/build_env.sh $DOCKERFILE_DIR $REQS_ARG $NO_CACHE
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
	"clean")
		NO_CACHE=""
                for (( i = 2; i <= $args_count; i++ ))
                do
                        case "$2" in
                                "--no-cache")
                                        echo "DISABLE CACHING"
                                        NO_CACHE="--no-cache"
                                        ;;
                                *)
                                        echo "UNKNOWN ARG: $2"
                                        ;;
                        esac
                        shift 1
                done

                CONTAINER_NAME=yocto_project
                CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)
                docker stop $CONTAINER_ID
                docker rm $CONTAINER_ID

                $CHECKS_DIR/yocto-image-check.sh
                CHECK_CODE=$?
                if [ $CHECK_CODE -eq 0 ]; then
                        IMAGE_NAME=yocto-image
                        IMAGE_ID=$(docker inspect --format="{{.Id}}" yocto-image)
                        docker rmi $IMAGE_ID
                fi 
                ./entrypoint.sh build_env --no-perf $NO_CACHE
                ;;
	"del_volume")
		echo "REMOVING POKY"
		rm -rf $DOCKERFILE_DIR/assembly/poky
		echo "REMOVING BUILD DIR"
		rm -rf $DOCKERFILE_DIR/assembly/build
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

