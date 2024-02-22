#! /bin/bash

image=$(docker images --filter "reference=buildroot-image*" --format "{{.Repository}}:{{.Tag}}")


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

echo "Creating: buildroot-image:$version"
docker build --tag "buildroot-image:$version" .

