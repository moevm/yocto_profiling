#! /bin/bash


DOCKERFILE_DIR=$1
REQS=$2
NO_CACHE=$3

USER_ID=$(id -u)
GROUP_ID=$(id -g)
CORE=$(uname -r)
CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d = -f 2)

if [[ ($USER_ID -eq 0) && ($GROUP_ID -eq 0) ]]; then
	echo -e "Perform this action as a non-root user, otherwise problems may arise with access rights to volume files."
	echo "Please change user!"
	exit 1
fi

VARS="--build-arg UID=$USER_ID \
	--build-arg GID=$GROUP_ID \
	--build-arg CORE=$CORE \
	--build-arg CODENAME=$CODENAME \
	--build-arg REQS_ARG=$REQS"

cd $DOCKERFILE_DIR
if [[ -z "$NO_CACHE" ]]; then
	docker compose build \
	$VARS
else
	docker compose build $NO_CACHE \
	$VARS
fi

