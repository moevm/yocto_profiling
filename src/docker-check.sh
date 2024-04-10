#! /bin/bash


if $(docker ps &>/dev/null) && [ $? -eq 0 ]; then
	echo "SUCCESS: docker is installed."
else
	echo "ERROR: docker is not installed."
	echo "More information can be found here: https://docs.docker.com/engine/install/"
        exit 1
fi

docker_compose_version=$(docker compose version --short)

if $(docker compose &>/dev/null) && [ $? -eq 0 ]; then
	echo -e "SUCCESS: docker compose (v$docker_compose_version) is installed."

elif [ -x "$(command -v docker-compose)" ]; then
	echo "docker-compose (v1) is installed."
	echo "Please update the docker compose plugin version! Requires version v2 or higher."
	echo "Try: sudo apt-get install docker-compose-plugin"
        exit 1

else
	echo "ERROR: neither \"docker-compose\" nor \"docker compose\" appear to be installed."
	exit 1
fi
