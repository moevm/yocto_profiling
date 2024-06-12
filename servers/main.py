import os
import sys
from typing import Optional

import docker
import docker.errors


def connect_to_docker() -> docker.DockerClient:
    try:
        cl = docker.from_env()
    except docker.errors.DockerException:
        sys.exit("An error occurred while retrieving docker information, check that docker is installed and running.")

    return cl


def variables_check(*, start_port: int = 9000, count_of_servers: int = 4) -> tuple[int, int]:
    def checks() -> bool:
        if (int != type(start_port)) or (type(count_of_servers) != int):
            return False
        if start_port < 1024:
            return False
        if count_of_servers < 2:
            return False

        return True

    if not checks():
        sys.exit('Variables check for PORTS and SERVER COUNT failed!')
    return start_port, count_of_servers


def find_image(cl: docker.DockerClient, image: str) -> bool:
    try:
        cl.images.get(image)
    except docker.errors.ImageNotFound:
        return False
    return True


def pull_reqs_images(cl: docker.DockerClient, *, images: Optional[list[str]] = None) -> None:
    if not images:
        return

    for image in images:
        if find_image(cl, image):
            continue

        try:
            cl.images.pull(image)
        except docker.errors.APIError as e:
            raise e

    return


def sstate_dir_check(*, path: str = './build/sstate-cache') -> str:
    if not (os.path.isdir(path) and os.listdir(path)):
        sys.exit('Directory with sstate-cache was not found or it is empty!')
    return path


def create_volume_list() -> tuple[list[str], str]:
    global SSTATE_DIR_PATH

    def create_volume(cache_dir: str) -> str:
        return f"{SSTATE_DIR_PATH}/{cache_dir}/:/sstate-cache/{cache_dir}/"

    volume_list, universal_volume = [], ''
    for elem in os.listdir(SSTATE_DIR_PATH):
        if not os.path.isdir(os.path.join(SSTATE_DIR_PATH, elem)):
            continue

        if elem == 'universal':
            universal_volume = create_volume(elem)
            continue

        volume_list.append(create_volume(elem))

    if not (volume_list and universal_volume):
        sys.exit('Volume list and universal volume was not found or it is empty!')

    return volume_list, universal_volume


def create_containers(cl: docker.DockerClient, *,
                      image: str = 'parted-sstate-cache:latest',
                      vol: tuple[list[str], str]) -> None:
    pass


def start_containers(cl: docker.DockerClient) -> None:
    pass


def build_base_image(cl: docker.DockerClient) -> None:
    cl.images.build(path='.', dockerfile='Dockerfile', tag=f'parted-sstate-cache:latest', forcerm=True)


if __name__ == "__main__":
    START_PORT, COUNT_OF_SERVERS = variables_check()
    SSTATE_DIR_PATH = sstate_dir_check()

    client = connect_to_docker()
    pull_reqs_images(client, images=['alpine:3.18'])
    build_base_image(client)

    volumes = create_volume_list()
    create_containers(client, vol=volumes)
    start_containers(client)

    # get container like:
    # container = client.containers.get('45e6d2de7c54')
