#! /bin/bash


container=$(docker ps -a -f name=buildroot --format "{{.Names}}")

if [[ -n "$container" ]]
then 
  echo "Container already exists."
  docker start -i "$container"
  exit 0
fi


image=$(docker images --filter "reference=buildroot-image*" --format "{{.Repository}}:{{.Tag}}")

if [[ -n "$image" ]]
then
  echo "Found: $image."
  docker run -it --name buildroot -v $PWD/assembly:/home/buildroot_user/project/assembly "$image"
else
  echo "The image wasn't found."
fi
