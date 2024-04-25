#! /bin/bash

cd $1

docker compose build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CORE=$(uname -r) --build-arg CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2) --build-arg REQS_ARG="$2"

