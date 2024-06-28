#!/bin/bash

IMAGE_NAME=hash

CONTAINERS=$(docker ps -a -q --filter ancestor=$IMAGE_NAME)

if [ -n "$CONTAINERS" ]; then
    echo "Found containers from $IMAGE_NAME image:"
    echo $CONTAINERS
    for CONTAINER in $CONTAINERS; do
        CONTAINER_STATUS=$(docker inspect --format '{{.State.Status}}' $CONTAINER)
        if [ "$CONTAINER_STATUS" == "running" ]; then
            echo "Stopping container $CONTAINER..."
            docker stop $CONTAINER
        fi
        echo "Removing container $CONTAINER..."
        docker rm $CONTAINER
    done
else
    echo "No containers found from $IMAGE_NAME image."
fi
