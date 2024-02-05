## Sequencing - последовательность действий во время сборки образа 
Образ ставился по инструкции (https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html)
- [x] 1) Установка библиотек и зависимостей; локали
- [x] 2) Клонирование репозитрия и выбор ветки
- [ ] 3) Сборка образа
- [ ] 4) Запуск qemu
### Шаг 1 - установка библиотек и зависимостей; локали
#### Установка зависимостей
С помощью команды установлены библиотеки: `sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales libacl1`  

Логи от вызова команды находятся в [Файле](docs/req1.txt) 
#### Установка локали
С помощью команды `sudo locale-gen en_US.UTF-8` установлена локаль
Логи от вызова команды находятся в [Файле](docs/set_local2.txt) 

### Шаг 2 - Клонирование репозитрия и выбор ветки
#### Клонирование репозитория
С помощью команды склонирован репозиторий: `git clone git://git.yoctoproject.org/poky`
#### Выбор ветки
С помощью команды выбрана ветка nanbield: `git checkout -t origin/nanbield`  
Логи от вызова команд находятся в [Файле](docs/clone_poky3.txt) 

### Шаг 3 - Сборка образа
#### Сборка образа в режиме развернутого логирования
С помощью команды запущена сборка образа: `bitbake core-image-sato -v`  
Сборка продолжалась 2.5 часа, завершилась с двумя ошибкам (самый конец логов представлен в [Файле](docs/build4.txt))  
Автоматических логгер сборщика сформировал [Файл](docs/log.do_compile.2952137)  
#### Сборка образа в режиме развернутого логирования с перенаправлением потока вывода в текстовый файл
С помощью команды запущена сборка образа c перенаправлением потока вывода: `bitbake core-image-sato -v >> log_build.txt`  
Логи терминала помещены в [Файл](docs/build4_2.txt) ; Логи с перенаправленного потока помещены в [Файл](docs/log_build.txt)  
Автоматических логгер сборщика сформировал [Файл](docs/log.do_compile.3537826)  

По всей видимости основная ошибка - `ERROR: gcc-13.2.0-r0 do_compile: ExecutionError('/home/autolab-user-center/yocto/poky/build/tmp/work/core2-64-poky-linux/gcc/13.2.0/temp/run.do_compile.3537826', 1, None, None)`

### Шаг 4 - Запуск qemu
#### Попытка запуска qemu
С помощью команды произведена попытка запуска qemu : `runqemu qemux86-64`   
Запуск не был произведен - появились ошибки (наверное, закономерно, поскольку 3 шаг прошел с ошибками)   
Логи ошибок из терминала помещены в [Файл](docs/quemu_run5.txt)
