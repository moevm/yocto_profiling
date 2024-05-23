#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly
if [ ! -d "./logs" ]; then
	echo "Create log dir."
	mkdir logs
fi

if [ ! -d "./poky" ]; then
	echo "Clone Poky."
	git clone git://git.yoctoproject.org/poky
fi

branch_name=my-upstream
commit_hash=1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a

cd $YOCTO_INSTALL_PATH/assembly/poky 
current_branch=$(git branch --show-current)
if [ "$current_branch" != "$branch_name" ]; then
	echo "Switch the branch."
	git checkout $commit_hash -b $branch_name
fi


cd $YOCTO_INSTALL_PATH/assembly

function start_logging() {
	# start utils for logging
	# $1 is txt file for logs
	# USE SUDO PLS 
	echo "Start building yocto:" >> $1
}

function finish_logging() {
	# finish utils for logging
	# $1 is txt file for logs
	# USE SUDO PLS
	echo "Completed building yocto!" >> $1
}


function decorate_logs() {
	log_file=$YOCTO_INSTALL_PATH/assembly/logs/building_logs.txt

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
	echo "yocto building ends with code: $?"
}


decorate_logs build_yocto

