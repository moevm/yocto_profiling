#!/bin/bash

EXPERIMENT_DIR=$(dirname "$(realpath $0)")

RESULTS_DIR=$EXPERIMENT_DIR/results
SRC_DIR=$EXPERIMENT_DIR/..

rm -rf $RESULTS_DIR


. $EXPERIMENT_DIR/auto_conf/read_config.sh
DEFAULT_CONFIG_FILE=$EXPERIMENT_DIR/auto_conf/experiment.conf
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
CACHE_SERVER_WORKDIR=$CACHE_DESKTOP_PATH/test/src
CACHE_SERVER_SETUPER_WORKDIR=$CACHE_SERVER_WORKDIR/experiment/cache_server_setuper
HASH_DESKTOP_PATH="/home/$hash_usr/Desktop"
HASH_SERVER_SETUPER_WORKDIR=$HASH_DESKTOP_PATH/test/hash_server_setuper


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

function setup_cache_servers() {
	if ssh $cache_usr@$cache_ip "[ ! -d $CACHE_DESKTOP_PATH/test/ ]";
	then
	    echo "Start setup cache servers."
	    ssh $cache_usr@$cache_ip "mkdir -p $CACHE_DESKTOP_PATH/test"
	    echo "Copying \"src\" dir: start"
	    rsync -aP $SRC_DIR --exclude $SRC_DIR/yocto-build/assembly/original_poky --exclude $SRC_DIR/yocto-build/assembly/poky --exclude $SRC_DIR/yocto-build/assembly/build $cache_usr@$cache_ip:$CACHE_DESKTOP_PATH/test/ 2> /dev/null
	    echo -e "Copying: done\n"
	    
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/.. && python3 -m venv venv"
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/.. && source venv/bin/activate"
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_WORKDIR/reqs && pip3 install -r requirements.txt" > /dev/null
	    echo -e "Installing requirements: done\n"
	    
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build-env --no-perf --no-cache" > /dev/null
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build-yocto --only-poky" > /dev/null
	    
	    echo -e "THEN USER MANUALLY CONNECT TO THIS SERVER AND EXEC BUILDING"
	    echo -e "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build-yocto"
	    exit 2
	fi
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_WORKDIR && ./manipulate_cache.sh kill" 2> /dev/null
}

function setup_hash_server() {
	echo "Hash server create dir: start"
	ssh $hash_usr@$hash_ip "rm -rf $HASH_DESKTOP_PATH/test"
	ssh $hash_usr@$hash_ip "mkdir -p $HASH_DESKTOP_PATH/test"
	echo "Hash server create dir: done"
	echo -e "\n"

	echo "Copying files and build hash server image: start"
	rsync -aP $EXPERIMENT_DIR/hash_server_setuper $hash_usr@$hash_ip:$HASH_DESKTOP_PATH/test/ > /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./build_env.sh"  2> /dev/null
	echo "Copying files and build hash server image: done"

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
setup_cache_servers
setup_hash_server

prepare_host


# LOOP
cd $SCRIPT_DIR
for (( i=2; i<$max_servers; i+=$step ))
do
	# подъём серверов
 	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./run_hash_container.sh $hash_port"  2> /dev/null
	echo -e "\n\nHash server started at $hash_ip:$hash_port"
 
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_WORKDIR && ./manipulate_cache.sh start $cache_start_port $i" > /dev/null
	cd $EXPERIMENT_DIR/auto_conf && python3 set_num_ports.py --cache_num_port $i
	echo -e "Building Yocto on host with $i servers: START.\n"

  cp -f $SRC_DIR/conf/experiment.conf $EXPERIMENT_DIR/auto_conf/conf/local.conf
  cd $EXPERIMENT_DIR/auto_conf && python3 auto_compose_local_conf.py
	echo -e "[CACHE SERVERS $i]" >> $EXPERIMENT_DIR/"times"
	for j in 1 2
	do
		filename="test_${i}_${j}"
		start=`date +%s`
		cd $SRC_DIR && ./entrypoint.sh build-yocto --no-layers --conf-file $EXPERIMENT_DIR/auto_conf/conf/local.conf > $RESULTS_DIR/"$filename"
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
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_WORKDIR && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_WORKDIR && ./manipulate_cache.sh kill" 2> /dev/null
	
	sleep 25
done

