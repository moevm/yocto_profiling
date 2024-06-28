#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly/scripts

case "$STAGE_VAR" in
	"sleep")
        	sleep infinity
		;;
	*)
		echo "Trying to build yocto-project."
		./building.sh
		;;
esac
