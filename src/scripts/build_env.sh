#! /bin/bash

USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [[ ($USER_ID -eq 0) && ($GROUP_ID -eq 0) ]]; then
	echo -e "Perform this action as a non-root user, otherwise problems may arise with access rights to volume files."
	echo "Please change user!"
	exit 1
fi

cd $1

if [[ -z "$3" ]]; then
	docker compose build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CORE=$(uname -r) --build-arg CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2) --build-arg REQS_ARG="$2"
else
	docker compose build $3 --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CORE=$(uname -r) --build-arg CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2) --build-arg REQS_ARG="$2"
fi

