#!/bin/bash

# USING: ./main.sh ./auto_conf/experiment.conf

SCRIPT_DIR=$(dirname "$(realpath $0)")

EXPERIMENT_DIR=$SCRIPT_DIR/..
BASE_DIR=$SCRIPT_DIR/../../..
SRC_DIR=$BASE_DIR/src

# Импортируем функцию парсинга config файла
. $SCRIPT_DIR/auto_conf/read_config.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 config_file"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
fi

# Парсим config файл 
process_config $1

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

cache_desktop_path="/home/$cache_usr/Desktop"
hash_desktop_path="/home/$hash_usr/Desktop"


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

# Cоздаем папку test на рабочем столе, если ее не было, иначе удаляем и создаем
# echo "Create clean test directory:"
# echo "Cache server: start"
# ssh $cache_usr@$cache_ip "rm -rf $cache_desktop_path/test"
# ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
# echo "Cache server: done"

echo "Hash server create dir: start"
ssh $hash_usr@$hash_ip "rm -rf $hash_desktop_path/test"
ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
echo "Hash server create dir: done"
echo -e "\n"


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


echo "Start hash server:"
rsync -aP $EXPERIMENT_DIR/hash_server_setuper $hash_usr@$hash_ip:$hash_desktop_path/test/ > /dev/null
ssh $hash_usr@$hash_ip "docker stop $(docker ps -q --filter ancestor=hash)" 2> /dev/null
ssh $hash_usr@$hash_ip "docker rm $(docker ps -q -a --filter ancestor=hash)" 2> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./build_docker_image_for_hash.sh"  2> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"  2> /dev/null
echo "Hash server started at $hash_ip:$hash_port"
echo -e "\n"


# echo "Prepare cache servers:"
cd $BASE_DIR

# 1. Копирование необходимых частей проекта:
# echo "Copying \"src\" and \"build\" dirs: start"
# rsync -aP ./src --exclude ./src/yocto-build/assembly/poky --exclude ./src/yocto-build/assembly/build $cache_usr@$cache_ip:$cache_desktop_path/test/ 2> /dev/null
# rsync -aP ./build $cache_usr@$cache_ip:$cache_desktop_path/test/ 2> /dev/null
# echo -e "Copying: done\n"

CACHE_SERVER_WORKDIR=$cache_desktop_path/test/src
# 2. Создание виртуального окружения и установка зависимостей.
# echo "Installing requirements: start"
# ssh $cache_usr@$cache_ip "python3 -m venv venv"
# ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/.. && source venv/bin/activate"
# ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/yocto-build/assembly/servers_reqs && pip3 install -r requirements.txt" > /dev/null
# echo -e "Installing requirements: done\n"

# 3. Сборка образа системы для Yocto
# echo "Buildint ENV: start"
# ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_env --no-perf" > /dev/null
# echo -e "Buildint ENV: done\n"

# 4. Клонирование poky
# echo "Cloning POKY: start"
# ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image --only-poky" > /dev/null
# echo -e "Cloning POKY: done\n"

# 5. Сборка Yocto
# echo "Building YOCTO: start"
# ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image"
# echo "Building YOCTO: done"
# echo -e "\n"


echo "Prepare host for build:"
cd $SRC_DIR

echo "Buildint ENV: start"
./entrypoint.sh build_env --no-perf > /dev/null
echo -e "Buildint ENV: done\n"

echo "Cloning POKY: start"
./entrypoint.sh build_yocto_image --only-poky > /dev/null
echo "Cloning POKY: done"
echo -e "\n"


# LOOP
# В папке ./build должен лежать конфиг сборки. Сейчас он учитывает доп слои. Нужно иметь его оригинал, для этого создаём временную папку save_orirginal_config, куда положим оригинальный конфиг
mkdir -p $BASE_DIR/build/save_orirginal_config
cp -f $BASE_DIR/build/conf/local.conf $BASE_DIR/build/save_orirginal_config/local.conf

cd $SCRIPT_DIR
for (( i=2; i<$max_servers; i+=$step ))
do
	# 6. Сборка и подъём кэш серверов
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh start $cache_start_port $i" > /dev/null

	cd $SCRIPT_DIR/auto_conf && python3 set_num_ports.py --cache_num_port $i
	echo -e "\n\nset cache_num_port = $i"
	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: START.\n"

    cp -f $BASE_DIR/build/conf/local_temp.conf $SCRIPT_DIR/auto_conf/conf/local.conf
    cd $SCRIPT_DIR/auto_conf && python3 auto_compose_local_conf.py
    cp -f $SCRIPT_DIR/auto_conf/conf/local.conf $BASE_DIR/build/conf/local.conf
	for j in 1 2
	do
		filename="test_${i}_${j}"
		cd $SRC_DIR && ./entrypoint.sh build_yocto_image >> $EXPERIMENT_DIR/"$filename"

		echo -e "Remove build folder\n"
		cd $SRC_DIR/yocto-build/assembly && rm -rf ./build
        	
		sleep 15
	done
	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: DONE.\n"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill"
	
	sleep 25
done
echo -e "BUILDING AND UPPING CACHE CONTAINERS: DONE."

cp -f $BASE_DIR/build/save_orirginal_config/local.conf $BASE_DIR/build/conf/local.conf


# Убиваем контейнер.
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
