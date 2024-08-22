#! /bin/bash

SCRIPTS_DIR=$PWD/scripts
PATCHES_DIR=$PWD/yocto-patches
CHECKS_DIR=$SCRIPTS_DIR/checks

DOCKERFILE_DIR=$PWD/yocto-build
POKY_DIR=$DOCKERFILE_DIR/assembly/poky

function help() {
        echo "This script is needed for interaction with the image of Yocto Project."
        echo "List of available parameters:"

        echo -e "\tbuild_env -- Builds an image of the virtual environment."
	echo -e "\t\t--no-perf -- Disables installation of the perf."
	echo -e "\t\t--no-cache -- Disables docker cache using."

	echo -e ""
	echo -e "\t*ONLY AFTER STAGE*: build_env"
        echo -e "\tshell -- Opens a terminal in container."
        echo -e "\tbuild_yocto_image -- Build the yocto image in container."
	echo -e "\t\t--only-poky -- Only clones poky instead of a full build."

	echo -e ""
	echo -e "\t*ONLY AFTER STAGE*: build_yocto_image"
	echo -e "\tstart_yocto -- Up the yocto image."
	
	echo -e ""
	echo -e "\tclean-docker -- Removing existing container and image of yocto."
	echo -e "\tclean-build -- Removing poky and build dir."

	echo -e ""
	echo -e "\tcheck -- Verify that dependencies are installed for the project."
	
	echo -e ""
        echo -e "\tpatch <list_of_patches> -- Patching the project. List like: <patch1>::<patch2>..."
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

args_count=$(($#-1))
p_command=$1
shift 1

for (( i = 0; i < $args_count; i++ ))
do
	args_arr[$i]=$1
	shift 1
done


EXIT_CODE=0
case "$p_command" in 
	"patch")
		if [[ ! -z "${args_arr[0]}" ]]; then
                        $SCRIPTS_DIR/patching.sh $POKY_DIR $PATCHES_DIR ${args_arr[0]}
		else
			echo "[WARNING]: No patches were found"
			help
		fi
		;;
	"build_env")
		REQS_ARG="perf"
		NO_CACHE=""

		for (( i = 0; i < $args_count; i++ ))
		do
			case "${args_arr[$i]}" in
				"--no-perf")
					echo "DISABLE PERF"
					REQS_ARG="requirements"
					;;
				"--no-cache")
					echo "DISABLE CACHING"
					NO_CACHE="--no-cache"
					;;
				*)
					echo "[WARNING]: Unknown arg: ${args_arr[$i]}"
					;;
			esac
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
                if [[ ! -z "${args_arr[0]}" ]]; then
                        if [[ "${args_arr[0]}" == "--only-poky" ]]; then
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
	"clean-docker")
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
	       	
                ./entrypoint.sh build_env --no-perf ${args_arr[@]}
                ;;
	"clean-build")
		echo "REMOVING POKY"
		rm -rf $DOCKERFILE_DIR/assembly/poky
		echo "REMOVING BUILD DIR"
		rm -rf $DOCKERFILE_DIR/assembly/build
		;;
	*)
		echo -e "[ERROR]: Unexpected parameter found <$p_command>!\n"
        	help
        	exit 1
		;;
esac


if [[ ! $EXIT_CODE -eq 0 ]]; then
	echo "Exit code: $EXIT_CODE"
	$CHECKS_DIR/active-container-check.sh

fi

