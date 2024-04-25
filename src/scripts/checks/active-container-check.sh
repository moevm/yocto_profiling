#! /bin/bash


CONTAINER_NAME=yocto_project
GET_RUN_CONTAINER=$(docker ps --format '{{.Names}}' | grep -- "$CONTAINER_NAME")

if [[ ! -z $GET_RUN_CONTAINER ]]; then
	cd $1
	docker compose stop
fi

