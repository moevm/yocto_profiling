#!/bin/bash

IMAGE_NAME=hash

CONTAINERS=$(docker ps -a -q --filter ancestor=$IMAGE_NAME)

if [ -n "$CONTAINERS" ]; then
    echo "Found containers from $IMAGE_NAME image:"
    echo $CONTAINERS
    for CONTAINER in $CONTAINERS; do
        CONTAINER_STATUS=$(docker inspect --format '{{.State.Status}}' $CONTAINER)
        if [ "$CONTAINER_STATUS" == "running" ]; then
            if [ "$1" == "stop" ]; then
                echo "Stopping container $CONTAINER..."
                docker stop $CONTAINER
            fi   
        fi
        if [ "$1" == "rm" ]; then
            echo "Removing container $CONTAINER..."
            docker rm $CONTAINER
        elif [ "$1" == "start" ]; then
            echo "Starting container $CONTAINER..."
            docker start $CONTAINER
        fi
    done
else
    echo "No containers found from $IMAGE_NAME image."
fi
