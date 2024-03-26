#! /bin/bash

sed -i "s/stage_build/stage_run/g" ./docker-compose.yml

docker-compose up -d
sed -i "s/stage_run/stage_build/g" ./docker-compose.yml
docker container exec -it yocto_project /bin/bash

docker-compose stop

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`

