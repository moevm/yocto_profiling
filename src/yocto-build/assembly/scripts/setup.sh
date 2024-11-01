#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly/scripts

case "$STAGE_VAR" in
	"sleep")
        	sleep infinity
		;;
	*)
		echo "Buiding script was executed!"
		./building.sh
		;;
esac
