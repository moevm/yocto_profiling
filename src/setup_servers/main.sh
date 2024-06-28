#!/bin/bash

# USING: ./main.sh ./auto_conf/experiment.conf 

# импортируем функцию парсинга config файла 
. ./auto_conf/read_config.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 config_file"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
fi

# парсим config файл 
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
echo "max_servsers = $max_servsers"

cache_desktop_path="/home/$cache_usr/Desktop"
hash_desktop_path="/home/$hash_usr/Desktop"


# Проверка подключения к hash серверу
if nc -zvw3 $hash_ip 22; then
    # Попытка подключения по SSH
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


# Проверка подключения к cache серверу
if nc -zvw3 $cache_ip 22; then
    # Попытка подключения по SSH
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


# создаем папку test на рабочем столе, если ее не было, иначе удаляеем и создаем
if ssh $cache_usr@$cache_ip "[ ! -d $cache_desktop_path/test ]"; then
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
else
    echo "Delete and make cleen cache test"
    ssh $cache_usr@$cache_ip "rm -rf $cache_desktop_path/test"
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
fi

# создаем папку test на рабочем столе, если ее не было, иначе удаляеем и создаем
if ssh $hash_usr@$hash_ip "[ ! -d $hash_desktop_path/test ]"; then
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
else
    echo "Delete and make cleen hash test"
    ssh $hash_usr@$hash_ip "rm -rf $hash_desktop_path/test"
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
fi


# Setup hash server :: Проблема - почему-то не работает >> /dev/null
scp -r ../hash_server_setuper/ $hash_usr@$hash_ip:$hash_desktop_path/test/ >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./build_docker_image_for_hash.sh"  >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"

echo "Hash server started at $hash_ip:$hash_port"


echo -e "PREPARE HOST FOR BUILD:"
echo -e "BUILDING ENV ON HOST: START."
../entrypoint.sh build_env --no-perf
echo -e "BUILDING ENV ON HOST: DONE."

echo -e "CLONING POKY ON HOST: START."
../entrypoint.sh build_yocto_image --only-poky
echo -e "CLONING POKY ON HOST: DONE."


# Работа с кэш серверами:
echo -e "PREPARE CACHE SERVERS:"

# 1. Копирование необходимых частей проекта:
echo -e "COPYING: START."
scp -r ../../src/ $cache_usr@$cache_ip:$cache_desktop_path/test/
scp -r ../../build/ $cache_usr@$cache_ip:$cache_desktop_path/test/
echo -e "COPYING: DONE."

CACHE_SERVER_WORKDIR=$cache_desktop_path/test/src

# 2. Сборка образа системы для Yocto
echo -e "BUILDING ENV: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_env --no-perf"
echo -e "BUILDING ENV: DONE."

# 3. Клонирование poky
echo -e "CLONING POKY: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image --only-poky"
echo -e "CLONING POKY: DONE."

# 4. Сборка Yocto
echo -e "BUILDING YOCTO: START."
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image"
echo -e "BUILDING YOCTO: DONE."

# LOOP
echo -e "BUILDING AND UPPING CACHE CONTAINERS: START."
for (( i=2; i < $max_servers; i += $step ))
do
	# 5. Сборка и подъём кэш серверов
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./tests.sh start $cache_start_port $i"
	python3 set_num_ports.py --cache_num_port $i

	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: START."
	for i in 1 2
	do
		# ГЕНЕРАЦИЯ КОНФИГОВ
		../entrypoint.sh build_yocto_image
	done
	echo -e "BUILDING YOCTO ON HOST WITH $i SERVERS: DONE."
done
echo -e "BUILDING AND UPPING CACHE CONTAINERS: DONE."


# Убиваем контейнер. Отлично убивается контейнер.
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./stop_hash.sh $hash_port"

# Убиваем кэш сервера
ssh $cache_usr@$cache_ip "cd $cache_desktop_path/test && ./tests.sh kill"


: '
Работаем в /home/user/Desctop/test на удаленных серверах
TBD:
1) Создание хэш сервера - копирование Docker образа и запуск его для клонирования poky; проверка на наличие poky; запуск хэш сервера, отключение хэш сервера
2) Создание кэш сервера - копирование Docker образа и запуск его для клонирования poky; запуск сборки, окончание сборки, выгрузка и парсинг логов, удаление рабочей директории
3) Оформить это все в цикл
'
