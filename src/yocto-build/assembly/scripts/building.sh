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

branch_name=my-upstream_5.0.1
commit_hash=$YOCTO_COMMIT_HASH

cd $YOCTO_INSTALL_PATH/assembly/poky 
current_branch=$(git branch --show-current)
if [ "$current_branch" != "$branch_name" ]; then
	echo "Switch the branch."
	git checkout $commit_hash -b $branch_name
fi


cd $YOCTO_INSTALL_PATH/assembly


if [[ "$STAGE_VAR" == "clone_poky" ]]; then
    echo "Only cloning because of breaking flag!"
    exit 0
fi

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


function build() {
	./scripts/add_layers.sh
	source $YOCTO_INSTALL_PATH/assembly/poky/oe-init-build-env $YOCTO_INSTALL_PATH/assembly/build/
	cp $YOCTO_INSTALL_PATH/conf/local.conf $YOCTO_INSTALL_PATH/assembly/build/conf/local.conf
	bitbake-layers show-layers
	bitbake core-image-minimal
	YOCTO_EXIT_CODE=$?
	echo "yocto building ends with code: $YOCTO_EXIT_CODE"
}

decorate_logs build

exit $YOCTO_EXIT_CODE
