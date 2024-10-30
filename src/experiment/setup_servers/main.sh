#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath $0)")

EXPERIMENT_DIR=$SCRIPT_DIR/..
RESULTS_DIR=$EXPERIMENT_DIR/results
SRC_DIR=$SCRIPT_DIR/..

rm -rf $RESULTS_DIR


. $SCRIPT_DIR/auto_conf/read_config.sh
DEFAULT_CONFIG_FILE=$SCRIPT_DIR/auto_conf/experiment.conf
process_config $DEFAULT_CONFIG_FILE

echo "USING $1"
echo "cache_ip = $cache_ip"
echo "cache_usr = $cache_usr"
echo "hash_ip = $hash_ip"
echo "hash_usr = $hash_usr"

echo "cache_start_port = $cache_start_port"
echo "cache_num_port = $cache_num_port"
echo "hash_port = $hash_port"
echo "step = $step"
echo "max_servers = $max_servers"
echo -e "\n"

CACHE_DESKTOP_PATH="/home/$cache_usr/Desktop"
HASH_DESKTOP_PATH="/home/$hash_usr/Desktop"

function check_ssh_connection() {
	if nc -zvw3 $hash_ip 22; then
	    if ssh -o ConnectTimeout=5 -o BatchMode=yes $hash_usr@$hash_ip true; then
	        echo "SSH connection to $hash_ip works"
	    else
	        echo "SSH connection to $hash_ip does not work"
	        exit 1
	    fi
	else
	    echo "Port 22 on $hash_ip is closed"
	    exit 1 
	fi
	
	
	if nc -zvw3 $cache_ip 22; then
	    if ssh -o ConnectTimeout=5 -o BatchMode=yes $cache_usr@$cache_ip true; then
	        echo "SSH connection to $cache_ip works"
	    else
	        echo "SSH connection to $cache_ip does not work"
	        exit 1
	    fi
	else
	    echo "Port 22 on $cache_ip is closed"
	    exit 1
	fi
	echo -e "\n"
}

function check_cache_server_deps() {
	EXIT_CODE=$(ssh $cache_usr@$cache_ip "which python3 || echo \$?")
	if [[ $EXIT_CODE ==  "1" ]];
	then
	    echo "No python3 was found"
	    exit 1
	fi
	echo "Python3 was found on cache server"
	EXIT_CODE=$(ssh $cache_usr@$cache_ip "which pip3 || echo \$?")
	if [[ $EXIT_CODE ==  "1" ]];
	then
	    echo "No pip3 was found"
	    exit 1
	fi
	echo "Pip3 was found on cache server"
	echo -e "\n"
}

function setup_and_start_hash_server() {
	echo "Hash server create dir: start"
	ssh $hash_usr@$hash_ip "rm -rf $hash_desktop_path/test"
	ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
	echo "Hash server create dir: done"
	echo -e "\n"

	echo "Start hash server:"
	rsync -aP $EXPERIMENT_DIR/hash_server_setuper $hash_usr@$hash_ip:$hash_desktop_path/test/ > /dev/null
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./build_docker_image_for_hash.sh"  2> /dev/null

	echo -e "\n"
}

function prepare_host () {
	echo "Prepare host for build:"
	cd $SRC_DIR
	
	echo "Buildint ENV: start"
	./entrypoint.sh build-env --no-perf > /dev/null
	echo -e "Buildint ENV: done\n"
	
	echo "Cloning POKY: start"
	./entrypoint.sh build-yocto --only-poky > /dev/null
	echo "Cloning POKY: done"
	echo -e "\n"
}


check_ssh_connection
check_cache_server_deps
setup_and_start_hash_server

CACHE_SERVER_WORKDIR=$CACHE_DESKTOP_PATH/test/src
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill" 2> /dev/null

prepare_host


# LOOP
cd $SCRIPT_DIR
for (( i=2; i<$max_servers; i+=$step ))
do
	# подъём серверов
 	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"  2> /dev/null
	echo -e "\n\nHash server started at $hash_ip:$hash_port"
 
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh start $cache_start_port $i" > /dev/null
	cd $SCRIPT_DIR/auto_conf && python3 set_num_ports.py --cache_num_port $i
	echo -e "Building Yocto on host with $i servers: START.\n"

    cp -f $SRC_DIR/conf/experiment.conf $SCRIPT_DIR/auto_conf/conf/local.conf
    cd $SCRIPT_DIR/auto_conf && python3 auto_compose_local_conf.py
	echo -e "[CACHE SERVERS $i]" >> $EXPERIMENT_DIR/"times"
	for j in 1 2
	do
		cp -f $SCRIPT_DIR/auto_conf/conf/local.conf $SRC_DIR/conf/local.conf
		filename="test_${i}_${j}"
		start=`date +%s`
		cd $SRC_DIR && ./entrypoint.sh build-yocto --no-layers --conf-file $SCRIPT_DIR/auto_conf/conf/local.conf > $RESULTS_DIR/"$filename"
		end=`date +%s`

		runtime=$((end-start))
		echo -e "REPEAT $j TIME: $runtime" >> $RESULTS_DIR/"times"
		cat $RESULTS_DIR/"$filename" | grep "Parsing recipes: 100% || Time:" >> $RESULTS_DIR/"times"
		cat $RESULTS_DIR/"$filename" | grep "Checking sstate mirror object availability: 100% || Time:" >> $RESULTS_DIR/"times"

		echo -e "Remove build folder\n"
		cd $SRC_DIR/yocto-build/assembly && rm -rf ./build

		sleep 15
	done
	echo -e "" >> $RESULTS_DIR/"times"
	echo -e "Building Yocto on host: DONE.\n"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill" 2> /dev/null
	
	sleep 25
done

