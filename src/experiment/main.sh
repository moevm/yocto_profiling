#!/bin/bash


ENTRYPOINT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
if [ -z $ENTRYPOINT_DIR ] || [ "os_profiling" != $(basename -s .git `git config --get remote.origin.url`) ]; then
  echo -e "You are not in the os_profiling cloned repo!"
  exit 2
fi
. $ENTRYPOINT_DIR/src/common/scripts/vars.sh
CURRENT_DIR=$(dirname "$(realpath $0)")

RESULTS_DIR=$CURRENT_DIR/results
rm -rf $RESULTS_DIR

. $CURRENT_DIR/auto_conf/read_config.sh
DEFAULT_CONFIG_FILE=$CURRENT_DIR/auto_conf/experiment.conf
process_config $DEFAULT_CONFIG_FILE

PATCHES=$1

echo "USING $PATCHES"
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

# Paths are broken, because currently entire os_profiling directory is copied,
# so path should include it. Fix it later
CACHE_DESKTOP_PATH="/home/$cache_usr/Desktop"
CACHE_TEST_DIR="/home/$cache_usr/Desktop/test"
CACHE_SRC_DIR=$CACHE_TEST_DIR
CACHE_SERVER_SETUPER_DIR=$CACHE_SRC_DIR/experiment/cache_server_setuper

HASH_DESKTOP_PATH="/home/$hash_usr/Desktop"
HASH_TEST_DIR="/home/$hash_usr/Desktop/test"
HASH_SERVER_SETUPER_DIR=$HASH_TEST_DIR/hash_server_setuper


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
	if ssh $cache_usr@$cache_ip "[ ! -d $CACHE_TEST_DIR ]";
	then
	    echo "Start setup cache servers."
	    ssh $cache_usr@$cache_ip "mkdir -p $CACHE_TEST_DIR"
	    echo "Copying \"src\" dir: start"
	    rsync -aP $ENTRYPOINT_DIR \
	    --exclude $ENTRYPOINT_DIR/tests \
	    --exclude $ENTRYPOINT_DIR/wiki \
	    --exclude $ENTRYPOINT_DIR/README.md \
	    --exclude $ASSEMBLY_DIR/original_poky \
	    --exclude $ASSEMBLY_DIR/poky \
	    --exclude $ASSEMBLY_DIR/build \
	    $cache_usr@$cache_ip:$CACHE_TEST_DIR/ 2> /dev/null
	    echo -e "Copying: done\n"
	    
	    ssh $cache_usr@$cache_ip "cd $CACHE_TEST_DIR/.. && python3 -m venv venv"
	    ssh $cache_usr@$cache_ip "cd $CACHE_TEST_DIR/.. && source venv/bin/activate"
	    ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_DIR/reqs && pip3 install -r requirements.txt" > /dev/null
	    echo -e "Installing requirements: done\n"
	    
	    ssh $cache_usr@$cache_ip "cd $CACHE_TEST_DIR && ./entrypoint.sh build-env --no-perf --no-cache" > /dev/null
	    ssh $cache_usr@$cache_ip "cd $CACHE_TEST_DIR && ./entrypoint.sh build-yocto --only-poky" > /dev/null
	    
	    echo -e "THEN USER MANUALLY CONNECT TO THIS SERVER AND EXEC BUILDING"
	    echo -e "cd $CACHE_TEST_DIR && ./entrypoint.sh build-yocto"
	    exit 2
	fi
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_DIR && ./manipulate_cache.sh kill" 2> /dev/null
}

function setup_hash_server() {
	echo "Hash server create dir: start"
	ssh $hash_usr@$hash_ip "rm -rf $HASH_TEST_DIR"
	ssh $hash_usr@$hash_ip "mkdir -p $HASH_TEST_DIR"
	echo "Hash server create dir: done"
	echo -e "\n"

	echo "Copying files and build hash server image: start"
	rsync -aP $CURRENT_DIR/hash_server_setuper $hash_usr@$hash_ip:$HASH_TEST_DIR/ > /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./build_env.sh"  2> /dev/null
	echo "Copying files and build hash server image: done"

	echo -e "\n"
}

function prepare_host () {
	echo "Prepare host for build:"
	cd $ENTRYPOINT_DIR
	
	echo "Building ENV: start"
	$ENTRYPOINT_DIR/entrypoint.sh build-env --no-perf > /dev/null
	echo -e "Buildint ENV: done\n"
	
	echo "Cloning POKY: start"
	$ENTRYPOINT_DIR/entrypoint.sh build-yocto --only-poky > /dev/null
	echo "Cloning POKY: done"
	
	if [ "$PATCHES" == "--patches" ]; then
		echo "Applying patches: start"
		$ENTRYPOINT_DIR/entrypoint.sh patch cachefiles.patch
		echo "Applying patches: done"
	fi

	echo -e "\n"
}


check_ssh_connection
check_cache_server_deps
setup_cache_servers
setup_hash_server

prepare_host


# LOOP
cd $CURRENT_DIR
mkdir -p $RESULTS_DIR
for (( i=2; i<$max_servers; i+=$step ))
do
	# подъём серверов
 	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./run_hash_container.sh $hash_port" 2> /dev/null
	echo -e "\n\nHash server started at $hash_ip:$hash_port"
 
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_DIR && ./manipulate_cache.sh start $cache_start_port $i" > /dev/null
	cd $CURRENT_DIR/auto_conf && python3 set_num_ports.py --cache_num_port $i
	echo -e "Building Yocto on host with $i servers: START.\n"

  cp -f $SRC_DIR/conf/experiment.conf $CURRENT_DIR/auto_conf/conf/local.conf
  python3 $CURRENT_DIR/auto_conf/auto_compose_local_conf.py
	echo -e "[CACHE SERVERS $i]" >> $RESULTS_DIR/"times"
	for j in 1 2
	do
		filename="test_${i}_${j}"
		start=`date +%s`
		$ENTRYPOINT_DIR/entrypoint.sh build-yocto --no-layers --conf-file $CURRENT_DIR/auto_conf/conf/local.conf > $RESULTS_DIR/"$filename"
		end=`date +%s`

		runtime=$((end-start))
		echo -e "REPEAT $j TIME: $runtime" >> $RESULTS_DIR/"times"
		cat $RESULTS_DIR/"$filename" | grep "Parsing recipes: 100% || Time:" >> $RESULTS_DIR/"times"
		cat $RESULTS_DIR/"$filename" | grep "Checking sstate mirror object availability: 100% || Time:" >> $RESULTS_DIR/"times"

		echo -e "Remove build folder\n"
		cd $ASSEMBLY_DIR && rm -rf ./build

		sleep 15
	done
	echo -e "" >> $RESULTS_DIR/"times"
	echo -e "Building Yocto on host: DONE.\n"
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./manipulate_hash.sh stop" 2> /dev/null
	ssh $hash_usr@$hash_ip "cd $HASH_SERVER_SETUPER_DIR && ./manipulate_hash.sh rm" 2> /dev/null
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_SETUPER_DIR && ./manipulate_cache.sh kill" 2> /dev/null
	
	sleep 25
done

