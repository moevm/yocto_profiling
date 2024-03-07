#! /bin/bash

image=$(docker images --filter "reference=yocto-image*" --format "{{.Repository}}:{{.Tag}}")

if [[ -n "$image" ]]
then
  docker rmi "$image"
fi

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --tag "yocto-image" .

