import argparse
import sys
import os
from typing import Optional, Union, Tuple, List

import docker
import docker.errors
from docker.models.containers import Container


def connect_to_docker() -> docker.DockerClient:
    try:
        cl = docker.from_env()
    except docker.errors.DockerException as e:
        raise Exception(
            f"An error occurred while retrieving docker information, check that docker is installed and running.\n{e}"
        )

    return cl


def checks(start_port: int, count_of_servers: int) -> bool:
    if (int != type(start_port)) or (type(count_of_servers) != int):
        return False
    if start_port < 1024:
        return False
    if count_of_servers < 2:
        return False

    return True


def variables_check(*, start_port: int = 9000, count_of_servers: int = 4) -> Tuple[int, int]:
    if not checks(start_port, count_of_servers):
        raise ValueError('Variables check for PORTS and SERVER COUNT failed!')
    return start_port, count_of_servers


def find_image(image: str) -> bool:
    try:
        CLIENT.images.get(image)
    except docker.errors.ImageNotFound:
        return False
    return True


def pull_reqs_images(*, images: Optional[List[str]] = None) -> None:
    if images is None or not images:
        return

    for image in images:
        if find_image(image):
            continue

        try:
            CLIENT.images.pull(image)
        except docker.errors.APIError as e:
            raise Exception(f"Error while pulling image {image}: {e}")

    return


def sstate_dir_check(*, path: str = '/build/sstate-cache') -> str:
    current_path = os.getcwd()
    result_path = current_path + path
    if not (os.path.isdir(result_path) and os.listdir(result_path)):
        raise OSError('Directory with sstate-cache was not found or it is empty!')
    return result_path


def create_volume_note(cache_dir: str) -> str:
    return f"{SSTATE_DIR_PATH}/{cache_dir}/:/app/sstate-cache/{cache_dir}/:ro"


def create_volumes() -> Tuple[List[str], str]:
    volume_list, universal_volume = [], ''
    for elem in os.listdir(SSTATE_DIR_PATH):
        if not os.path.isdir(os.path.join(SSTATE_DIR_PATH, elem)):
            continue

        if elem == 'universal':
            universal_volume = create_volume_note(elem)
            continue

        volume_list.append(create_volume_note(elem))

    if not (volume_list and universal_volume):
        raise Exception('Volume list and universal volume was not found or it is empty!')

    print(f"Created volumes for sstate-cache:", *volume_list, sep='\n', end='\n\n')
    print(f"Created volume for universal sstate-cache:", universal_volume, sep='\n', end='\n')
    return volume_list, universal_volume


def container_creator(*, image: str, name: str, port: int, volume: Union[List[str], str]) -> Container:
    try:
        container = CLIENT.containers.create(
            image=image,
            name=f"cache-{name}",
            ports={
                f'{PORT_INSIDE_CONTAINER}/tcp': port
                },
            environment={
                "PORT": PORT_INSIDE_CONTAINER
                },
            volumes=volume,
        )
    except docker.errors.APIError as e:
        raise Exception(f"Error while creating containers, retry or delete already exists containers. {e}")

    return container


def create_containers(*, image: str, vol: Tuple[List[str], str]) -> Tuple[Container, ...]:
    parted_vol, universal_vol = vol

    if not find_image(image):
        raise docker.errors.ImageNotFound("Base image not found!")

    remove_exists_containers(image=image)

    # create container for universal cache dir
    containers: list[Container] = [
        container_creator(
            image=image,
            name='universal',
            port=START_PORT + COUNT_OF_SERVERS - 1,
            volume=[universal_vol]
        )
    ]

    # create containers for parted cache
    for i in range(COUNT_OF_SERVERS - 1):
        containers.append(
            container_creator(
                image=image,
                name=f'part-{i}',
                port=START_PORT + i,
                volume=parted_vol[i::COUNT_OF_SERVERS - 1]
            )
        )

    return tuple(containers)


def start_containers(*, image: str, containers: Tuple[Container, ...]) -> None:
    for container in containers:
        try:
            container.start()
        except docker.errors.APIError as e:
            remove_exists_containers(image=image)
            raise e


def remove_exists_containers(*, image: str) -> None:
    exists_containers = CLIENT.containers.list(all=True, filters={'ancestor': image})
    if exists_containers:
        for container in exists_containers:
            remove_container(container)


def remove_container(container: Container) -> None:
    try:
        container.remove(force=True)
    except docker.errors.APIError:
        raise docker.errors.APIError(
            "Error while removing container, check \'docker ps -a\' that it was removed successfully!"
        )


def stop_container(container: Container) -> None:
    try:
        container.stop(force=True)
    except docker.errors.APIError:
        raise docker.errors.APIError(
            "Error while stopping container, check list of containers!"
        )


def build_base_image(*, tag: str) -> None:
    try:
        image, _ = CLIENT.images.build(path=CONTEXT, dockerfile='Dockerfile', tag=tag, forcerm=True)
    except (docker.errors.BuildError, docker.errors.APIError) as e:
        raise Exception(f'An error occurred while building base image! {e}')
    except TypeError as e:
        raise e


def option_create() -> Tuple:
    pull_reqs_images(images=['alpine:3.18'])
    build_base_image(tag=IMAGE_NAME)

    volumes = create_volumes()
    container_tuple = create_containers(image=IMAGE_NAME, vol=volumes)
    return container_tuple


def option_start(containers: Tuple[Container, ...]) -> None:
    start_containers(image=IMAGE_NAME, containers=containers)


def option_kill() -> None:
    remove_exists_containers(image=IMAGE_NAME)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('action', type=str, nargs='?', choices=['create', 'start', 'kill'])
    parser.add_argument('-p', '--port', type=int, default=9000)
    parser.add_argument('-c', '--count', type=int, default=4)
    parser.add_argument('--path', type=str, default='/build/sstate-cache')
    parser.add_argument('--context', type=str, default=os.path.dirname(os.path.realpath(sys.argv[0])) + '/servers_reqs')

    args = parser.parse_args()

    START_PORT, COUNT_OF_SERVERS = variables_check(start_port=args.port, count_of_servers=args.count)
    SSTATE_DIR_PATH = sstate_dir_check(path=args.path)
    CONTEXT = args.context

    CLIENT = connect_to_docker()
    IMAGE_NAME: str = 'parted-sstate-cache:latest'
    PORT_INSIDE_CONTAINER: int = 9000

    if args.action == 'create':
        option_create()
    elif args.action == 'start':
        create_result = option_create()
        option_start(create_result)
    elif args.action == 'kill':
        option_kill()
    else:
        raise Exception('No actions! Try: python3 main.py -h')
