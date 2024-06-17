#!/bin/bash

. ./read_config.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 config_file"
    return 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    return 1
fi


process_config $1


echo "cache_ip = $cache_ip"
echo "cache_usr = $cache_usr"
echo "hash_ip = $hash_ip"
echo "hash_usr = $hash_usr"
echo "cache_start_port = $cache_start_port"
echo "cache_num_port = $cache_num_port"
echo "hash_port = $hash_port"
