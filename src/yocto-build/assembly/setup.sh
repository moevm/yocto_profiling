#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly/scripts

case "$SCRIPT" in 
	"stage_run")
		echo "Try to start yocto-project."
        	sleep infinity
		;;
	"stage_build")
		echo "Trying to build yocto-project."
		./building.sh
		;;
	*)
		echo "Wrong setup param!"
		;;
esac

