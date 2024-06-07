### Файл автоматической конфигурации local.conf
Разработан файл `auto_compose_local_conf.py`, который в текущей вариации должен запускаться из папки build. Правильно ли это или нет - пока не понятно, будет понятно на этапе реализации оркестрирования сборок во время проведения экспериментов. 

Для того, чтобы файл работал корректно нужно, чтобы рядом с ним находились 2 txt файла:
1) servers_params.txt -- должен создаваться автоматически и должен содеражать 2 значения через пробел
  - порт, начиная с которого будет начинаться размещение кэш серверов
  - количество серверов и, соотвественно, портов
  
**EX: 9000 5**
 
2) hash_params.txt -- должен создаваться автоматически и должен содеражать 2 значения через двоеточие `:`
  - IP адресс хэш сервера
  - порт, на котором размещен хэш сервер
     
**EX: 10.138.70.6:9999**

Программа заменяет conf/local.conf таким же файлам, но:
1) убирает комментарии
2) автоматически описывает зеркала с кэшем и хэш сервера

### Пример выходного файла
После выполнения команды `python3 auto_compose_local_conf.py`

Исходный local.conf заменяется на подобный этому:
```bash
MACHINE ??= "qemux86-64"
DISTRO ?= "poky"
EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
USER_CLASSES ?= "buildstats"
PATCHRESOLVE = "noop"
BB_DISKMON_DIRS ??= "\
    STOPTASKS,${TMPDIR},1G,100K \
    STOPTASKS,${DL_DIR},1G,100K \
    STOPTASKS,${SSTATE_DIR},1G,100K \
    STOPTASKS,/tmp,100M,100K \
    HALT,${TMPDIR},100M,1K \
    HALT,${DL_DIR},100M,1K \
    HALT,${SSTATE_DIR},100M,1K \
    HALT,/tmp,10M,1K"
PACKAGECONFIG:append:pn-qemu-system-native = " sdl"
SSTATE_MIRRORS ?= "\ 
file://.* http://10.138.70.218:9000/server_folder_9000/sstate-cache/PATH;downloadfilename=PATH \ 
file://.* http://10.138.70.218:9001/server_folder_9001/sstate-cache/PATH;downloadfilename=PATH \ 
file://.* http://10.138.70.218:9002/server_folder_9002/sstate-cache/PATH;downloadfilename=PATH \ 
file://.* http://10.138.70.218:9003/server_folder_9003/sstate-cache/PATH;downloadfilename=PATH \ 
file://.* http://10.138.70.218:9004/server_folder_9004/sstate-cache/PATH;downloadfilename=PATH"

BB_HASHSERVE = "auto" 
BB_HASHSERVE_UPSTREAM = "10.138.70.6:9999" 
BB_SIGNATURE_HANDLER = "OEEquivHash" 

CONF_VERSION = "2"
```
