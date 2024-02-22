#! /bin/bash

image=$(docker images --filter "reference=buildroot-image*" --format "{{.Repository}}:{{.Tag}}")


if [[ -n "$image" ]]
then
  echo "Found: $image."
  docker run -it --rm -v $PWD/scripts:/home/buildroot_user/scripts "$image"
else
  echo "The image wasn't found."
fi
