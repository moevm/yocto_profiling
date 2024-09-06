#!/bin/bash

# USING: ./main.sh ./auto_conf/experiment.conf

SCRIPT_DIR=$pwd
EXPERIMENT_DIR=$SCRIPT_DIR/..
BASE_DIR=$SCRIPT_DIR/../../..
SRC_DIR=$BASE_DIR/src

# Импортируем функцию парсинга config файла
. ./auto_conf/read_config.sh

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


# Cоздаем папку test на рабочем столе, если ее не было, иначе удаляем и создаем
if ssh $cache_usr@$cache_ip "[ ! -d $cache_desktop_path/test ]"; then
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
else
    echo "Delete and make cleen cache test"
    ssh $cache_usr@$cache_ip "rm -rf $cache_desktop_path/test"
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
fi

if ssh $hash_usr@$hash_ip "[ ! -d $hash_desktop_path/test ]"; then
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
else
    echo "Delete and make cleen hash test"
    ssh $hash_usr@$hash_ip "rm -rf $hash_desktop_path/test"
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
fi


ssh $cache_usr@$cache_ip "pip3 list"
ssh $cache_usr@$cache_ip "python3 --version && which python3"


echo "Start hash server."
rsync -aP $EXPERIMENT_DIR/hash_server_setuper $hash_usr@$hash_ip:$hash_desktop_path/test/ >> /dev/null
ssh $hash_usr@$hash_ip "docker stop $(docker ps -q --filter ancestor=hash)" >> /dev/null
ssh $hash_usr@$hash_ip "docker rm $(docker ps -q -a --filter ancestor=hash)" >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./build_docker_image_for_hash.sh"  >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"
echo "Hash server started at $hash_ip:$hash_port"


echo -e "PREPARE HOST FOR BUILD:"
cd $SRC_DIR

echo -e "BUILDING ENV ON HOST: START."
./entrypoint.sh build_env --no-perf >> /dev/null
echo -e "BUILDING ENV ON HOST: DONE."

echo -e "CLONING POKY ON HOST: START."
./entrypoint.sh build_yocto_image --only-poky >> /dev/null
echo -e "CLONING POKY ON HOST: DONE."

cd $BASE_DIR
echo -e "PREPARE CACHE SERVERS:"
# 1. Копирование необходимых частей проекта:
echo -e "COPYING: START."
rsync -aP /src $cache_usr@$cache_ip:$cache_desktop_path/test/ >> /dev/null
rsync -aP /build $cache_usr@$cache_ip:$cache_desktop_path/test/ >> /dev/null
echo -e "COPYING: DONE."

CACHE_SERVER_WORKDIR=$cache_desktop_path/test/src
# 2. Создание виртуального окружения и установка зависимостей.
echo 'Installing requirements start'
ssh $cache_usr@$cache_ip "python3 -m venv venv"
ssh $cache_usr@$cache_ip "source venv/bin/activate"
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/yocto-build/assembly/servers_reqs && pip3 install -r requirements.txt" 
echo 'Installing requirements complete'

# 3. Сборка образа системы для Yocto
echo -e "BUILDING ENV: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_env --no-perf" >> /dev/null
echo -e "BUILDING ENV: DONE."

# 4. Клонирование poky
echo -e "CLONING POKY: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image --only-poky" >> /dev/null
echo -e "CLONING POKY: DONE."

# 5. Сборка Yocto
echo -e "BUILDING YOCTO: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image"
echo -e "BUILDING YOCTO: DONE."

# LOOP
# В папке /build должен лежать конфиг сборки. Сейчас он учитывает доп слои. Нужно иметь его оригинал, для этого создаём временную папку save_orirginal_config, куда положим оригинальный конфиг
mkdir /build/save_orirginal_config
cp -f $SCRIPT_DIR/auto_conf/build/conf/local.conf /build/save_orirginal_config/local.conf

cd $SCRIPT_DIR
for (( i=2; i<$max_servers; i+=$step ))
do
	# 6. Сборка и подъём кэш серверов
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh start $cache_start_port $i"

	cd /auto_conf && python3 set_num_ports.py --cache_num_port $i && cd -
	echo "set cache_num_port = $i"
	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: START."
	for j in 1 2
	do
		# pushd ../yocto-build/assembly/poky && . oe-init-build-env build && popd
		cp -f $BASE_DIR/build/save_orirginal_config/local.conf /auto_conf/conf/
        	cd /auto_conf && python3 auto_compose_local_conf.py && cd -
        	cp -f /auto_conf/conf/local.conf $BASE_DIR/build/conf/
        	
		filename="test_${i}_${j}"
        	cd $SRC_DIR && ./entrypoint.sh build_yocto_image >> $EXPERIMENT_DIR/"$filename" && cd -

        	echo "Remove build folder."
        	cd $SRC_DIR/yocto-build/assembly && rm -rf ./build && cd -
        	
		sleep 5
	done
	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: DONE."
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill"
	
	# sleep на всякий случай
	sleep 10
done
echo -e "BUILDING AND UPPING CACHE CONTAINERS: DONE."


# Убиваем контейнер. Отлично убивается контейнер.
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
# Убиваем кэш сервера
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill"


