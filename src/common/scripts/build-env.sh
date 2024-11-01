#! /bin/bash


DOCKERFILE_DIR=$1
REQS=$2
NO_CACHE=$3

USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [[ ($USER_ID -eq 0) && ($GROUP_ID -eq 0) ]]; then
	echo -e "Perform this action as a non-root user, otherwise problems may arise with access rights to volume files."
	echo "Please change user!"
	exit 1
fi

cd $DOCKERFILE_DIR
if [[ -z "$NO_CACHE" ]]; then
	docker compose build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CORE=$(uname -r) --build-arg CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2) --build-arg REQS_ARG="$REQS"
else
	docker compose build $NO_CACHE --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg CORE=$(uname -r) --build-arg CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2) --build-arg REQS_ARG="$REQS"
fi

