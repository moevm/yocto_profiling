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
docker build --tag "yocto-image:$version" .

