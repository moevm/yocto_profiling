#!/bin/bash


# The argument needs to be passed - the server identification is based on port
PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port>"
    echo "The argument needs to be passed - the server identification is based on port"
    exit 1
fi


docker run -d -p $PORT:8888 hash
