#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly/scripts

case "$STAGE_VAR" in 
	"stage_run")
        	sleep infinity
		;;
	*)
		echo "Trying to build yocto-project."
		./building.sh
		;;
esac

