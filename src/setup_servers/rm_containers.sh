#!/bin/bash

containers=$(docker ps -q -f status=running)

if [ -z "$containers" ]; then
    echo "No running containers found."
    exit 0
fi

docker stop $containers

sleep 5

docker rm $containers

echo "All running containers stopped and removed."
