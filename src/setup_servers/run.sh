#!/bin/bash

PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

current_dir=$(pwd)

docker run -d -p $PORT:$PORT -e PORT=$PORT -v $current_dir/server_folder_$PORT:/app/server_folder_$PORT my-http-server

