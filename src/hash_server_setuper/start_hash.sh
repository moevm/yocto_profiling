#!/bin/bash


# The argument needs to be passed - the server identification is based on port
PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port>"
    echo "The argument needs to be passed - the server identification is based on port"
    exit 1
fi

HOST_IP=$(python3 get_ip.py)

docker run -d -p $PORT:$PORT -e PORT=$PORT -e HOST_IP=$HOST_IP hash
