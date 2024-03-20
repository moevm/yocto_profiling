#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly
if [ ! -d "./logs" ]; then
	mkdir logs
fi

if [ ! -d "./poky" ]; then
	git clone git://git.yoctoproject.org/poky
fi


cd $YOCTO_INSTALL_PATH/assembly/poky 
branch=$(git branch --show-current)
if [ "$branch" != "my-nanbield" ]; then
	echo "Switch the branch."
	git checkout -t origin/nanbield -b my-nanbield
fi


cd $YOCTO_INSTALL_PATH/assembly

function start_logging() {
	# start utils for logging
	# $1 is txt file for logs
	echo "Start building yocto:" >> $1
}

function finish_logging() {
	# finish utils for logging
	# $1 is txt file for logs
	echo "Completed building yocto!" >> $1
}


function decorate_logs() {
	log_file=./logs/building_logs.txt

	if [ $# -eq 0 ]; then
		echo "You can use wrapper function. It takes any function with args and logs output to <./logs/building_logs.txt>"
		return 1
	fi

	func_to_log="$1"
	cp /dev/null $log_file

	# logging
	start_logging $log_file
	$func_to_log $@ 2>&1
	finish_logging $log_file
}

function build_yocto() {
	source $YOCTO_INSTALL_PATH/assembly/poky/oe-init-build-env 
	bitbake core-image-minimal
}

# entrypoint
decorate_logs build_yocto
