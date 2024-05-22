#!/bin/bash

PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

docker run -d -p $PORT:$PORT -e PORT=$PORT my-http-server

