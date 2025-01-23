# **Instructions**
> Для образа потребуется не менее 90Gb памяти. Процесс сборки займёт более 2 часов (зависит от выделенных ресурсов).

> Для выполнения следующих шагов необходим `Docker` и `Docker compose v2`!

Необходимо клонировать репозиторий. Это можно выполнить следующей командой:
```
git clone https://github.com/moevm/os_profiling.git
```

## **Yocto**
Для удобного взаимодействия с проектом был реализован скрипт `entrypoint.sh`, далее рассмотрим его функционал.
1. Функционал скрипта:
    ```
    ./entrypoint.sh
    ```
   
    После выполнения команды будет выведена информационная справка по использованию скрипта, возможные аргументы и т.д. 
    ```text
    Usage: entrypoint [ env | build-env ]
                --no-perf -- disables installation of the perf
                --no-cache -- disables docker cache using

              *required stage build-env*
              [ sh | shell ]
              [ by | build-yocto ]
                  --only-poky -- only clones poky repo
                  --no-layers -- build yocto image without layers and dependencies
                  --tracing <tool> -- enables tracing of the build with one of the tools (perf, ftrace, strace)
                  --conf-file <path> -- config file to use (works only for --no-layers)

              *required cloned poky*
              [ p | patch ] <list_of_patches>
                  -r, --reverse -- disable choosen patches
                  -l, --patches-list -- print available patches

              *required built yocto*
              [ sy | start-yocto ]

              [ cd | clean-docker ]
              [ cb | clean-build ]
                  -o, --orig -- also cleans original poky dir
              [ deps | install-deps ]
              [ check ]
    ```
   
2. Проверка установки всех необходимых зависимостей:
    ```shell
    ./entrypoint.sh check
    ```
    После выполнения команды произойдёт проверка всех необходимых зависимостей, для каждой из которых будет выведен статус, а далее общий результат. Пример:
    ```text
    SUCCESS: docker is installed.
    SUCCESS: docker compose (v2.25.0) is installed.
    
    Verification completed successfully!
    ```
    
3. Образ среды для проекта:
    ```shell
    ./entrypoint.sh env
    ```
    После выполнения команды начнётся сборка образа с помощью Docker. 
    При необходимости можно отключить утилиту `perf`, для этого к предыдущей команде необходимо добавить флаг `--no-perf`. Как это примерно должно выглядеть:
    ```text
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

4. Командная строка контейнера:
    ```shell
    ./entrypoint.sh shell
    ```
    После выполнения команды будет запущен контейнер и открыт терминал. Должно получиться следующее:
    ```text
    [+] Running 1/1
     ✔ Container yocto_project  Started 
    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.
    
    yocto_user@7212e2e38268:~/project$ 
    ...
    ```

5. Сборка образа Yocto:
    ```shell
    ./entrypoint.sh by
    ```
    После выполнения команды начнётся сборка образа `Yocto` внутри контейнера, когда произойдет автоматическое закрытие контейнера (с кодом 0) -- всё будет установлено. При необходимости можно только склонировать `poky`, для этого к предыдущей команде необходимо добавить флаг `--only-poky`.
    
    Пример удачной сборки:
    ```text
    [+] Running 1/1
    Attaching to yocto-container
    ...
    yocto-container  | You can also run generated qemu images with a command like 'runqemu qemux86-64'.
    yocto-container  | 
    yocto-container  | Other commonly useful commands are:
    yocto-container  |  - 'devtool' and 'recipetool' handle common recipe tasks
    yocto-container  |  - 'bitbake-layers' handles common layer tasks
    yocto-container  |  - 'oe-pkgdata-util' handles common target package tasks
    yocto-container  | 
    yocto-container  | Build Configuration:
    yocto-container  | BB_VERSION           = "2.7.3"
    yocto-container  | BUILD_SYS            = "x86_64-linux"
    yocto-container  | NATIVELSBSTRING      = "universal"
    yocto-container  | TARGET_SYS           = "x86_64-poky-linux"
    yocto-container  | MACHINE              = "qemux86-64"
    yocto-container  | DISTRO               = "poky"
    yocto-container  | DISTRO_VERSION       = "4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
    yocto-container  | TUNE_FEATURES        = "m64 core2"
    yocto-container  | TARGET_FPU           = ""
    yocto-container  | meta                 
    yocto-container  | meta-poky            
    yocto-container  | meta-yocto-bsp       = "my-upstream:1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
    yocto-container  | 
    yocto-container  | Initialising tasks...
    yocto-container  | done.
    yocto-container  | NOTE: Executing Tasks
    ...
    yocto-container  | NOTE: Tasks Summary: Attempted 4099 tasks of which 4099 didn't need to be rerun and all succeeded.
    yocto-container exited with code 0
    ```

6. Запуск образа Yocto:
    ```shell
    ./entrypoint.sh sy
    ```
    После выполнения будет открыта авторизация в системе `Yocto`, которая будет выглядеть так:
    ```text
    ...
    Poky (Yocto Project Reference Distro) 4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a qemux86-64 /dev/ttyS0

    qemux86-64 login: 
    ```
    Все действия далее описаны в разделе ["Работа с Yocto"](#Работа-с-Yocto).
7. Для применения патчей реализован команды, примеры использования:

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

### **Работа с Yocto**
Для авторизации в системе необходимо указать `login`, его значение `root`.
Поздравляю, вы получили доступ к системе.
Выход из системы осуществляется 2 способами:
- `Ctrl + A`, + `X`
- `Ctrl + A`, + `C`, + type `quit`

### **Анализ сборки**
Для анализа был разработан [набор скриптов](src/common/analysis). 

Для их корректной работы необходимо установить зависимости (скрипт полностью автоматизирован только для систем Linux):
```shell
./entrypoint.sh deps
```
После выполнения команды произойдёт создание виртуального окружения `venv`, его активация и установка всех необходимых зависимостей.

Если у вас уже есть виртуальное окружение:
```shell
source <path-to-venv>/bin/activate
pip install -r <project-path>/requirements.txt
```

Деактивация окружения:
```shell
deactivate
```


# **Experiments**
- [Эксперимент с cache серверами](wiki/experiments/experiment_results/README.md)
- [Эксперимент c checking mirors патчем](wiki/experiments/checking_mirrors_cache_experiment/README.md)

## Checking mirrors patch usage (fast instruction)

### Index file for sstate-cache

* Основной патч `cachefiles.patch`: добавляет проверку на индекс файл на сервере, и если он есть, то использует информацию из него для оптимизации поиска на удаленных кэш-серверах
  * Если нет index файла, то используется прошлая схема
* На кэш-сервере должен быть index файл. Местоположение: `$path_to_sstate_cache_dir/index.txt`
* Индекс файл можно получить двумя способами:
  * Через патч `compose_indexfile.patch`, который после завершения сборки создаст index файл в папке с `sstate-cache`
  * Через отдельный скрипт, который можно использовать уже на имеющемся кэше (*работает на python!*)
  ```python
  import os
  import sys

  if __name__ == "__main__":
      if len(sys.argv) < 2:
          print(f"USAGE: {sys.argv[0]} </path/to/sstate_dir>")
          exit(1)
      directory = sys.argv[1]
      output_file = os.path.join(directory, 'index.txt')
      with open(output_file, 'w') as f:
          for root, dirs, files in os.walk(directory):
              for file in files:
                  file_path = os.path.join(root, file)
                  relative_path = os.path.relpath(file_path, directory)
                  f.write(f"{relative_path}\n")
    ```

### Mirrors availability

* Патч `async_filter_with_time.patch`: добавляет проверку на доступность зеркал с кэшом по протоколу tcp
  * Должно работать из коробки

### Net limitation

* Патчи:
  * `add_net_buildstats.patch` добавляет сбор статистики по использованию сети. Сохраняет результаты в файлы `reduced_proc_net.log`, `net_pressure.log` и `current_max_pressure.log`
  * `add_net_limit.patch` добавляет достижение лимита сети при выборе задачи из очереди (если достигнут лимит, то выбирается *build* задача вместо *fetch*)
  * Должно работать из коробки


### Task reweighing

* Основной патч `add_task_children_to_weight.patch`: увеличивает приоритет задачам, которые имеют большее количество потомков в графе зависимостей
  * ***Для работы необходим файл `task-children.txt`!***
* Вспомогательный файл `task-children.txt` содержит информацию о потомках для каждой задачи. Как его получить:
  * Выгрузить из yocto граф зависимостей: `bitbake -g $your_image_recipe`
  * Запустить [утилиту для анализа](./src/common/analysis/): `python3 main.py -g task_children -d $path_to_generated_task_depends.dot`
  * Файл `task-children.txt` будет лежать в [`dep_graph/text-files/task-children.txt`](./src/common/analysis/dep_graph/text-files/)
  * Скопировать полученный файл в папку `poky/build`
  * После этого патч при запуске сборки начнёт работать

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
