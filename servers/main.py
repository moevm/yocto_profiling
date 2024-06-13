import os
from typing import Optional, Union

import docker
import docker.errors
from docker.models.containers import Container


def connect_to_docker() -> docker.DockerClient:
    try:
        cl = docker.from_env()
    except docker.errors.DockerException as e:
        raise docker.errors.DockerException(
            f"An error occurred while retrieving docker information, check that docker is installed and running.\n{e}"
        )

    return cl


def variables_check(*, start_port: int = 9000, count_of_servers: int = 4) -> tuple[int, int]:
    def checks() -> bool:
        nonlocal start_port, count_of_servers

        if (int != type(start_port)) or (type(count_of_servers) != int):
            return False
        if start_port < 1024:
            return False
        if count_of_servers < 2:
            return False

        return True

    if not checks():
        raise ValueError('Variables check for PORTS and SERVER COUNT failed!')
    return start_port, count_of_servers


def find_image(cl: docker.DockerClient, image: str) -> None:
    try:
        cl.images.get(image)
    except docker.errors.ImageNotFound as e:
        raise e
    return


def pull_reqs_images(cl: docker.DockerClient, *, images: Optional[list[str]] = None) -> None:
    if not images:
        return

    for image in images:
        find_image(cl, image)
        try:
            cl.images.pull(image)
        except docker.errors.APIError as e:
            raise e

    return


def sstate_dir_check(*, path: str = './build/sstate-cache') -> str:
    if not (os.path.isdir(path) and os.listdir(path)):
        raise OSError('Directory with sstate-cache was not found or it is empty!')
    return path


def create_volume_list() -> tuple[list[str], str]:
    global SSTATE_DIR_PATH

    def create_volume(cache_dir: str) -> str:
        global SSTATE_DIR_PATH
        return f"{SSTATE_DIR_PATH}/{cache_dir}/:/app/sstate-cache/{cache_dir}/"

    volume_list, universal_volume = [], ''
    for elem in os.listdir(SSTATE_DIR_PATH):
        if not os.path.isdir(os.path.join(SSTATE_DIR_PATH, elem)):
            continue

        if elem == 'universal':
            universal_volume = create_volume(elem)
            continue

        volume_list.append(create_volume(elem))

    if not (volume_list and universal_volume):
        raise Exception('Volume list and universal volume was not found or it is empty!')

    return volume_list, universal_volume


def create_containers(cl: docker.DockerClient, *,
                      image: str,
                      vol: tuple[list[str], str]) -> tuple[Container, ...]:
    global COUNT_OF_SERVERS, START_PORT
    parted_vol, universal_vol = vol

    find_image(cl, image)

    def create(*, name: str, port: dict[str, int], volume: Union[list[str], str]) -> Container:
        nonlocal image

        try:
            container = cl.containers.create(
                image,
                name=f"cache-{name}",
                ports=port,
                volumes=volume,
                read_only=True
            )
        except docker.errors.APIError as e:
            raise e

        return container

    def create_port(port: int) -> dict[str, int]:
        return {f'{port}/tcp': port}

    # create container for universal cache dir
    containers: list[Container] = [
        create(name='universal', port=create_port(START_PORT + COUNT_OF_SERVERS - 1), volume=universal_vol)
    ]

    # TODO сделать деление по (COUNT_OF_SERVERS - 1) серверам
    # create containers for parted cache
    for i in range(COUNT_OF_SERVERS - 1):
        containers.append(create(name=f'part-{i}', port=create_port(START_PORT + i), volume=[]))

    return tuple(containers)


def start_containers(cl: docker.DockerClient, containers: tuple[Container, ...]) -> None:
    # containers[i].start()
    ...


def kill_containers(cl: docker.DockerClient, containers: tuple[Container, ...]) -> None:
    ...


def build_base_image(cl: docker.DockerClient) -> str:
    try:
        image, _ = cl.images.build(path='.', dockerfile='Dockerfile', tag=f'parted-sstate-cache:latest', forcerm=True)
    except (docker.errors.BuildError, docker.errors.APIError) as e:
        raise Exception(f'An error occurred while building base image! {e}')
    except TypeError as e:
        raise e

    return image.tags[0]


if __name__ == "__main__":
    START_PORT, COUNT_OF_SERVERS = variables_check()
    SSTATE_DIR_PATH = sstate_dir_check()

    client = connect_to_docker()
    pull_reqs_images(client, images=['alpine:3.18'])
    image_name = build_base_image(client)

    volumes = create_volume_list()
    create_containers(client, image=image_name, vol=volumes)
