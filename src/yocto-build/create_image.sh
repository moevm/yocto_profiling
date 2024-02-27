#! /bin/bash

image=$(docker images --filter "reference=yocto-image*" --format "{{.Repository}}:{{.Tag}}")


if [[ -n "$image" ]]
then
  echo "Found: $image. Trying to delete."
  docker rmi "$image"
fi

if [[ -n "$1" ]]
then
  version="$1"
else
  version="unselected"
fi

echo "Creating: yocto-image:$version"
docker build --build-arg host_uid=$(id -u) --build-arg host_gid=$(id -g) --tag "yocto-image:$version" .

