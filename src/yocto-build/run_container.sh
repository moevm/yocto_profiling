#! /bin/bash

STAGE_VAR="stage_run" docker compose up -d
docker container exec -it yocto_project /bin/bash

docker compose stop

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`

