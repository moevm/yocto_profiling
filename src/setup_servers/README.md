### Instruction -- Step-by-Step Guide for Conducting the Experiment
1) Настраиваем ssh, как показано в [инструкции](/wiki/yocto_cache/ssh_connection.md)
2) Заполняем файл [конфигуарции](src/setup_servers/auto_conf/experiment.conf)  
-  a) `cache_ip` `hash_ip` -- ip адреса ваших кэш и хэш серверов соответсвенно (это те, которые вы настроили на шаге 1)
-  b) `cache_usr` `hash_usr` -- имена пользователей ваших кэш и хэш серверов (это те, которые вы настроили на шаге 1)
-  с) `hash_port` -- порт, на котором будет размещен хэш сервер
-  d) `cache_start_port` -- порт на кэш сервере, начиная с которого будеи размещено `cache_num_port`
-  e) `cache_num_port` -- количество портов, на которых размещаются кэш сервера; соответственно заняты будут порты, начиная с {`cache_start_port`} и до {`cache_start_port` + `cache_num_port` - 1}.
-  f) `step` -- шаг, с которым будет происходить итератор теста
-  g) `max_servsers` -- верхняя граница тестового диапазона

3) Если вы задали конфигурационный файл и настроили ssh - можно запускать скрипт `./main.sh ./auto_conf/experiment.conf`.
4) В ходе проведения эксперимента в корне репозитория автоматически создаются файлы формата `test_n_m`, где n - количество кэш серверов, m - номер повторения. Таким образом если m=1, то это значит, что сборка осуществляется без кэша хэш сервера, а если m=2, то с кэшем хэш сервера.
5) Если все прошло успешно то можно парсить файлы так: `cat file_name | grep "Checking sstate"` -- вам нужна строка `Checking sstate mirror object availability: 100% |#################################################################################################################################################################################################################| Time:` -- после двоеточия будет время сверки сигнатур.
6) Дальше по данным можно строить график

### Как работает эксперимент
#### Хэш сервер
Все, что нужно для его работы находится в `src/hash_server_setuper`, в этой же папке есть README.md. Работает без нареканий и багов.
#### Кэш сервер
Точкая входа в работу с кэш сервером - `src/tests.sh`.
#### Анализ main.sh
1. импорт конфигурации
```bash
. ./auto_conf/read_config.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 config_file"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
fi

# парсим config файл 
process_config $1

echo "USING $1"
echo "cache_ip = $cache_ip"
echo "cache_usr = $cache_usr"
echo "hash_ip = $hash_ip"
echo "hash_usr = $hash_usr"
echo "cache_start_port = $cache_start_port"
echo "cache_num_port = $cache_num_port"
echo "hash_port = $hash_port"
echo "step = $step"
echo "max_servers = $max_servers"
```
2. проверка доступности компьютеров по ssh
```bash
   if nc -zvw3 $hash_ip 22; then
    if ssh -o ConnectTimeout=5 -o BatchMode=yes $hash_usr@$hash_ip true; then
        echo "SSH connection to $hash_ip works"
    else
        echo "SSH connection to $hash_ip does not work"
        exit 1
    fi
else
    echo "Port 22 on $hash_ip is closed"
    exit 1 
fi


if nc -zvw3 $cache_ip 22; then
    if ssh -o ConnectTimeout=5 -o BatchMode=yes $cache_usr@$cache_ip true; then
        echo "SSH connection to $cache_ip works"
    else
        echo "SSH connection to $cache_ip does not work"
        exit 1
    fi
else
    echo "Port 22 on $cache_ip is closed"
    exit 1
fi
```
3. Работа на удаленных пк ведется в папке test на рабочем столе. Чтобы избежать проблем перед запуском теста эта папка удаляется, если она была до этого и создается заново

```bash
# создаем папку test на рабочем столе, если ее не было, иначе удаляеем и создаем
if ssh $cache_usr@$cache_ip "[ ! -d $cache_desktop_path/test ]"; then
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
else
    echo "Delete and make cleen cache test"
    ssh $cache_usr@$cache_ip "rm -rf $cache_desktop_path/test"
    ssh $cache_usr@$cache_ip "mkdir -p $cache_desktop_path/test"
fi

# создаем папку test на рабочем столе, если ее не было, иначе удаляеем и создаем
if ssh $hash_usr@$hash_ip "[ ! -d $hash_desktop_path/test ]"; then
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
else
    echo "Delete and make cleen hash test"
    ssh $hash_usr@$hash_ip "rm -rf $hash_desktop_path/test"
    ssh $hash_usr@$hash_ip "mkdir -p $hash_desktop_path/test"
fi
```
4. Копирования файлов для хэш сервера на удаленный пк и запуск сервера

```bash
scp -r ../hash_server_setuper/ $hash_usr@$hash_ip:$hash_desktop_path/test/ >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./build_docker_image_for_hash.sh"  >> /dev/null
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"
```
5. Запуск Docker локально для создания образа и клонирования poky
```bash
./entrypoint.sh build_env --no-perf >> /dev/null
./entrypoint.sh build_yocto_image --only-poky >> /dev/null
```

6. Копирования файлов для кэш сервера на удаленный пк, установка зависимостей и генерация кэша
```bash
scp -r ../../src/ $cache_usr@$cache_ip:$cache_desktop_path/test/ >> /dev/null
scp -r ../../build/ $cache_usr@$cache_ip:$cache_desktop_path/test/ >> /dev/null
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR/yocto-build/assembly/servers_reqs && pip3 install -r requirements.txt"
# сборка образа 
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_env --no-perf" >> /dev/null
# клонирование poky
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image --only-poky" >> /dev/null
# сборка yocto для генерации кэша
ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./entrypoint.sh build_yocto_image"
```
7. В `build/conf/local.conf` лежит конфигурация local.conf, котрая будет проброшена в контейнер для запуска сборки. По умолчанию в ней находится стандартная конфигурация с нашими слоями. Чтобы нам не потерять исходную конфигурацию, но пробросить в контейнер конфигурацию с учетом кэш и хэш серверов, конфигурация копируется в build/save_orirginal_config.  
```bash
mkdir ../../build/save_orirginal_config
cp -f ../../build/conf/local.conf ../../build/save_orirginal_config/local.conf
```


8. Цикл эксперимента -- ниже он оснащен комментариями для описания того, что происходит внутри
```bash
# Цикл идет от 2, т.к. в реализации кэш сервера нельзя взять 1 сервер 
for (( i=2; i<$max_servers; i+=$step ))
do
	# Распределение кэша из шага 6 и поднятие http серверов 
	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./tests.sh start $cache_start_port $i"
   # В конфигурационный файл эксперимента вносится текущее значение того, на сколько серверов распределен sstate-cache
	cd ./auto_conf && python3 set_num_ports.py --cache_num_port $i && cd -
	for j in 1 2
	do
        # копирование local.conf для того, чтобы автоматически сконфигурироать его
        cp -f ../../build/save_orirginal_config/local.conf ./auto_conf/conf/
        # автоматическая конфигурация local.conf
        cd ./auto_conf/ && python3 auto_compose_local_conf.py && cd -
        # копирование нового local.conf для проброса внутрь контейнера сборки с заменой старого local.conf
        cp -f ./auto_conf/conf/local.conf ../../build/conf/
        # генерация уникального имени файла в который будут собираться логи 
        filename="test_${i}_${j}"
        # сбор логов путем перевода потока вывода в корень проекта в файл с вышесгенерированным именем
        cd .. && ./entrypoint.sh build_yocto_image >> ../"$filename" && cd -
        # удаление папки сборки для того, чтобы локальный кэш не влиял на последующие сборки
        cd ../yocto-build/assembly && rm -rf ./build && cd -
        sleep 5
        # sleep на всякий случай
	done
   # после того, как дважды сборка произошла нужно остановить и удалить контейнер с хэш сервером и запустить его заново для очистки базы данных хэш сервера
 	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
	ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"
   # после того, как дважды сборка произошла нужно остановить и удалить контейнеры с кэш сервером запустятся они в начале следющей итерации
   ssh $cache_usr@$cache_ip "cd $cache_desktop_path/test/src && ./tests.sh kill"
   sleep 10
   # sleep на всякий случай
done
```

9. Выключаем все запущенные контейнеры на удаленных пк
```bash
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop"
ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm"
ssh $cache_usr@$cache_ip "cd $cache_desktop_path/test && ./tests.sh kill"
```

### Results -- TBD
Результаты будут помещаться в папку `./result/`
Например, результат сборки если запущен только один сервер с кэшем представлен в `./result/stats_1_server.png`, а если 50, то в `./result/stats_50_server.png`.   
Эти графики не очень полезны в рамках задачи, т.к. они не отображают, сколько по времени занимала валидация сигнатур кэша, так, для 1 сервера, она заняла у меня 0.5 минуты, а для 50 серверов - 8.5 минут.

