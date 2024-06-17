#!/bin/bash

# USING: ./main.sh ./auto_conf/experiment.conf 

# импортируем функцию парсинга config файла 
. ./auto_conf/read_config.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 config_file"
    return 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    return 1
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
