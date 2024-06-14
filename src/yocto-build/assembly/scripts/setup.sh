#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly/scripts

case "$STAGE_VAR" in
	"stage_run")
        	sleep infinity
		;;
	"clone_poky")
		echo "Trying to clone yocto-project without building"
		./building.sh "just_cloning" 
		;;
	*)
		echo "Trying to build yocto-project."
		./building.sh 
		;;
esac
