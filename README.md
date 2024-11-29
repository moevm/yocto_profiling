# **Instructions**
> Для образа потребуется не менее 90Gb памяти. Процесс сборки займёт более 2 часов (зависит от выделенных ресурсов).

> Для выполнения следующих шагов необходим `Docker` и `Docker compose v2`!

Необходимо клонировать репозиторий. Это можно выполнить следующей командой:
```
git clone https://github.com/moevm/os_profiling.git
```
Все дальнейшие шаги происходят в директории `src`.

- ### **Yocto**
    Для удобного взаимодействия был реализован скрипт `entrypoint.sh`, далее рассмотрим его функционал.
    1. Чтобы узнать какой функционал реализован в скрипте можно выполнить команду:
        ```
        ./entrypoint.sh
        ```
        После выполнения команды будет выведена информационная справка по использованию скрипта, то есть возможные аргументы и т.д. 
        ```text
        This script is needed for interaction with the image of Yocto Project.
        List of available parameters:
	        build_env -- Builds an image of the virtual environment.
		        --no-perf -- Disables installation of the perf.
		        --no-cache -- Disables docker cache using.

	        *ONLY AFTER STAGE*: build_env
	        shell -- Opens a terminal in container.
	        build_yocto_image -- Build the yocto image in container.
		        --only-poky -- Only clones poky instead of a full build.

	        *ONLY AFTER STAGE*: build_yocto_image
	        start_yocto -- Up the yocto image.

	        clean-docker -- Removing existing container and image of yocto.
	        clean-build -- Removing poky and build dir.

	        check -- Verify that dependencies are installed for the project.

	        patch <list_of_patches> -- Patching the project.
		        -r, --reverse -- Disable choosen patches.
		        -l, --patches-list -- Print available patches.
        ```
       
    2. Чтобы проверить установку всех необходимых зависимостей локально требуется выполнить команду:
        ```
        ./entrypoint.sh check
        ```
        После выполнения команды произойдёт проверка всех необходимых зависимостей, для каждой из которых будет выведен статус, а далее общий результат. Пример:
        ```
        SUCCESS: docker is installed.
        SUCCESS: docker compose (v2.25.0) is installed.
        
        Verification completed successfully!
        ```
        
    3. Чтобы создать образ среды для проекта требуется выполнить команду:
        ```
        ./entrypoint.sh build_env
        ```
        После выполнения команды начнётся сборка образа с помощью docker. 
        При необходимости можно отключить утилиту `perf`, для этого к предыдущей команде необходимо добавить флаг `--no-perf`. Как это примерно должно выглядеть:
        ```
        [+] Building (12/12) FINISHED                                                                  docker:default
         => [yocto_project internal] load build definition from Dockerfile                                     
         => => transferring dockerfile: 2.24kB                                                                 
         => [yocto_project internal] load metadata for docker.io/library/ubuntu:20.04                          
         => [yocto_project internal] load .dockerignore                                                        
        ...
         => [yocto_project] exporting to image      
         => => exporting layers
         => => writing image sha256:...
         => => naming to docker.io/library/yocto-image          
        ```
    
    4.  Чтобы получить доступ к файловой системе контейнера требуется выполнить команду:
        ```
        ./entrypoint.sh shell
        ```
        После выполнения команды будет запущен контейнер и открыт терминал. Должно получиться следующее:
        ```
        [+] Running 1/1
         ✔ Container yocto_project  Started 
        To run a command as administrator (user "root"), use "sudo <command>".
        See "man sudo_root" for details.
        
        yocto_user@7212e2e38268:~/project$ 
        ...
        ```
    
    5.  Чтобы собрать образ Yocto требуется выполнить команду:
        ```
        ./entrypoint.sh build_yocto_image
        ```
        После выполнения команды начнётся сборка образа `Yocto` внутри контейнера, когда произойдет автоматическое закрытие контейнера (с кодом 0) -- всё будет установлено. При необходимости можно только склонировать `poky`, для этого к предыдущей команде необходимо добавить флаг `--only-poky`.
        
        Пример удачной сборки:
        ```
        [+] Running 1/1
        Attaching to yocto_project
        ...
        yocto_project  | You can also run generated qemu images with a command like 'runqemu qemux86-64'.
        yocto_project  | 
        yocto_project  | Other commonly useful commands are:
        yocto_project  |  - 'devtool' and 'recipetool' handle common recipe tasks
        yocto_project  |  - 'bitbake-layers' handles common layer tasks
        yocto_project  |  - 'oe-pkgdata-util' handles common target package tasks
        yocto_project  | 
        yocto_project  | Build Configuration:
        yocto_project  | BB_VERSION           = "2.7.3"
        yocto_project  | BUILD_SYS            = "x86_64-linux"
        yocto_project  | NATIVELSBSTRING      = "universal"
        yocto_project  | TARGET_SYS           = "x86_64-poky-linux"
        yocto_project  | MACHINE              = "qemux86-64"
        yocto_project  | DISTRO               = "poky"
        yocto_project  | DISTRO_VERSION       = "4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
        yocto_project  | TUNE_FEATURES        = "m64 core2"
        yocto_project  | TARGET_FPU           = ""
        yocto_project  | meta                 
        yocto_project  | meta-poky            
        yocto_project  | meta-yocto-bsp       = "my-upstream:1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
        yocto_project  | 
        yocto_project  | Initialising tasks...
        yocto_project  | done.
        yocto_project  | NOTE: Executing Tasks
        ...
        yocto_project  | NOTE: Tasks Summary: Attempted 4099 tasks of which 4099 didn't need to be rerun and all succeeded.
        yocto_project exited with code 0
        ```
    
    7.  Чтобы запустить образ Yocto требуется выполнить команду:
        ```
        ./entrypoint.sh start_yocto
        ```
        После выполнения будет открыта авторизация в системе `Yocto`, которая будет выглядеть так:
        ```
        ...
        Poky (Yocto Project Reference Distro) 4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a qemux86-64 /dev/ttyS0

        qemux86-64 login: 
        ```
        Все действия далее описаны ниже.
    8.  Для применения патчей реализован команды, примеры использования:

        Применить патч buildstats_netstats.patch.
        ```shell
        ./entrypoint.sh patch buildstats_netstats.patch
        ```

        Можно применить сразу несколько патчей, тогда просто передаём их список.
        ```shell
        ./entrypoint.sh patch buildstats_netstats.patch poky_dir.patch
        ```

        Откатить патч buildstats_netstats.patch.
        ```shell
        ./entrypoint.sh patch buildstats_netstats.patch -r
        ```
        Аналогично можно откатить список патчей.

        Получить список доступных патчей.
        ```shell
        ./entrypoint.sh patch -l
        ```

- ### **Работа с Yocto**
    Для авторизации в системе необходимо указать `login`, его значение `root`.
    Поздравляю, вы получили доступ к системе.
    Выход из системы осуществляется 2 способами:
    - `Ctrl + A`, + `X`
    - `Ctrl + A`, + `C`, + type `quit`
        
- ### **Логирование**
    В скрипте `building.sh` реализован декоратор для предоставления возможности настройки логирования. Скрипт находится по пути `./assembly/scripts/building.sh`. Важно, что все команды позволяющие использовать утилиты для логирования необходимо выполнять строго под `sudo`.
    
    Для того, чтобы настроить и использовать нужные утилиты объявлены функции `function start_logging()` и `function finish_logging()`. Функции позволяют задавать необходимую реализацию логирования. Также в функции перёдаётся аргумент (`$1`) -- файл для логирования по умолчанию (`./assembly/logs/building_logs.txt`).

## Патч проверки доступности серверов SSTATE_MIRRORS
### Проблематика
Проблема заключается в том, что если указаны нерабочие сервера в `SSTATE_MIRRORS`, то эти нерабочие сервера опрашиваются на наличие кэша, что повышает процесс `Checking sstate mirror object availability`
### Решение
Решение заключается в том, что на стадии парсинга файла `local.conf` производится асинхронный опрос адресов из переменной `SSTATE_MIRRORS` и те, которые доступны, перезаписываются в переменную `SSTATE_MIRRORS`, о чем выводится `Warning`. Патч, реализующий этот функционал - [async_with_time_and_domains.patch](./src/yocto-patches/async_filter_with_time.patch).
### Применить патч
Чтобы применить этот патч, необходимо перенести его в корень репозитория poky и выполнить команду `git apply async_filter_with_time.patch`
### Проверка
1. Нужно применить патч.
2. В `local.conf` нужно указать hash сервер
3. В `local.conf` нужно указать в переменную SSTATE_MIRRORS рабочие сервера и нерабочие сервера
4. Провести сборку с помощью `bitbake <target>`
5. Во время сборки нужно смотреть на логи, выведется сообщение "Time from the start to end of checking sstate availability =="
    
# **Experiments**

- [Experiment with cache servers](wiki/experiments/experiment_results/README.md)

