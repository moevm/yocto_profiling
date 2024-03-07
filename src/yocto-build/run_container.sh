#! /bin/bash

container=$(docker ps -a -f name=yocto_project --format "{{.Names}}")

if [[ -n "$container" ]]
then 
  docker start -i "$container"
  exit 0
fi


image=$(docker images --filter "reference=yocto-image*" --format "{{.Repository}}:{{.Tag}}")

if [[ -n "$image" ]]
then
  docker run -it --name yocto_project -v $PWD/assembly:/home/yocto_user/project/assembly "$image"
else
  echo "The image wasn't found."
fi
