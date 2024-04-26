## Настройка зеркал кэша [без использования хэш сервера]
### Подготовка
Для того, чтобы подключиться к удаленному серверу кэша, необходимо этот удаленный кэщ сервер настроить по [инструкции](./yocto_cache/setup_http_server.md).

### Конфигурация удаленной сборки с испольщование простого зеракла
Необходимо произвести стандартные операции по началу сборки:
1) cd poky
2) sorce oe-init-build-env
3) поменять файл /poky/buid/conf/local.conf следующим образом:
```sh
MACHINE ??= "qemux86-64" 
DL_DIR ?= "${TOPDIR}/downloads"
SSTATE_DIR ?= "${TOPDIR}/sstate-cache"
DISTRO ?= "poky"
PACKAGE_CLASSES ?= "package_ipk"
# все что выше - не важно в контексте настройки заркал


SOURCE_MIRROR_URL ?= "\
file://.* http://127.0.0.1:8000/downloads/PATH;downloadfilename=PATH"

SSTATE_MIRRORS ?= "\
file://.* http://127.0.0.1:8000/sstate-cache/PATH;downloadfilename=PATH"


# все что ниже - не важно в контексте настройки заркал, но в будущем будет важно для настройки хэш сервера
BB_HASHSERVE = "auto"
BB_SIGNATURE_HANDLER = "OEEquivHash"
CONF_VERSION = "2"
```
**Важное зачмечание!**
`file://.* http://127.0.0.1:8000/downloads/PATH;downloadfilename=PATH`  <- эта строка будет работать у меня, поскольку у меня кэш сервер поднят на локальном хосте (потому ip 127.0.0.1) на порту 8000 (потому порт 8000) и сразу же в корне сервера у меня находится downloads (потому, после указания сервера и ip я пишу downloads или sstate-cache -- если у вас дерево ФС на сервере имеет другой вид - нужно прописывать полный путь от корня сервера до указанных папок) 

### Проверка корректности работы зеркал
С описанными настройками необходимо запустить сборку с помощью команды `bitbake -k core-image-minimal` (или другой образ).   
Если все сделано верно (в плане настройки сервера и зеркал), то при запуске, вы увидите следующие логи:  
![Screenshot from 2024-04-26 14-16-42](https://github.com/moevm/os_profiling/assets/90711883/b7df7be5-7894-4407-b670-1b1225569f5e)

Давайте рассмотрим, что здесь написано:
1) мы начали параметры работы hashserver, но не запустили его и не указали на какой машине и порту он поднят, логи об это:  
`WARNING: You are using a local hash equivalence server but have configured an sstate mirror. This will likely mean no sstate will match from the mirror. You may wish to disable the hash equivalence use (BB_HASHSERVE), or use a hash equivalence server alongside the sstate mirror.`
2) поскольку мы не подняли хэш сервер - не загрузились собранные зависимоти, загрузились скомпилированные исходник, загрузки исходного код и прочее, потому в логах мы увидем   
`Sstate summary: Wanted 1781 Local 0 Mirrors 882 Missed 899 Current 0 (49% match, 0% complete)`
Видно, что из зеркал загрузилось 882 кэшированные задачи, 899 не загрузились (потому что мы не настроили хэшсервер)
