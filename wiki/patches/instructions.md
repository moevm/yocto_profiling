
Список доступных патчей:
- [buildstats_timestamps.patch](#buildstats_timestampspatch)
- [buildstats_netstats.patch](#buildstats_netstatspatch)
- [pid.patch](#pidpatch)
- [runqueue.patch](#runqueuepatch)
- [poky_dir.patch](#poky_dirpatch)
- [cachefiles.patch](#cachefilespatch)


## buildstats_timestamps.patch

Сбор информации в форме временных рядов. Структура собранной информации.

Полученные временные ряды будут находиться в папке `build/tmp/buildstats/{package_name}`. Названия файлов с временными
рядами имеют шаблон `{task_name}_timestamps`.

Пример содержимого файла `{task_name}_timestamps`:
```text
...
Timestamp: 2024-06-25 17:45:13
RAM: VmPeak: 147628 kB, VmSize: 147628 kB, VmHWM: 59252 kB, VmRSS: 59252 kB
IO Stats: rchar: 576639, wchar: 47799, syscr: 53, syscw: 46, read_bytes: 0, write_bytes: 36864, cancelled_write_bytes: 0
...
```

Где: 
- `RAM` - информация о потреблении памяти:
  - `VmPeak` - максимальное использование памяти
  - `VmSize` - размер виртуальной памяти. Виртуальная память отображает общий объем адресного пространства, выделенного процессу для его работы. Это включает все доступные адреса, которые процесс может потенциально использовать
  - `VmHWM` - максимальное использование физической памяти
  - `VmRSS` - текущий объем реальной (физически используемой) оперативной памяти, занимаемой процессом
Другие возможные параметры:
  - `VmData` - размер данных, отражает объем физической памяти, используемой процессом для хранения данных
  - `VmStk` - размер стека, показывает объем памяти, выделенной под стек вызовов для процесса
  - `VmExe` - размер исполняемого кода, отражает объем памяти, занятой исполняемым кодом программы
  - `VmLib` - размер библиотек, показывает объем памяти, занятый библиотеками, загруженными процессом
  - `VmLck` - объем заблокированной в памяти страницы. Заблокированная память означает, что страница данных никогда не будет выгружена (swapped) из оперативной памяти на диск. Это гарантирует, что данные всегда будут доступны в оперативной памяти и не будут подвергаться операциям свопинга. Однако сама страница может перемещаться в пределах физической памяти системы. Это может происходить, например, при оптимизации использования физической памяти ядром операционной системы.
  - `VmPin` - объем закрепленной памяти. Закрепленная память представляет собой специализированный случай заблокированной памяти. В отличие от обычной заблокированной памяти, закрепленная память фактически привязывается к конкретному местоположению (странице) в физической памяти операционной системы. Это означает, что страница закрепленной памяти не только не будет выгружена на диск, но и не будет перемещаться в пределах оперативной памяти.
  - `VmPTE` - размер таблицы страниц. Таблицы страниц служат для отображения виртуальных адресов процесса на физические адреса в оперативной памяти. Каждая запись в таблице страниц (PTE) содержит информацию о соответствии между виртуальным и физическим адресами.
  - `RssAnon` - объем оперативной памяти, который процесс использует для анонимных страниц. Анонимные страницы — это страницы виртуальной памяти, которые не связаны с каким-либо файлом в файловой системе.
  - `RssFile` - объем физической памяти, который процесс использует для страниц, связанных с файлами в файловой системе. Эти страницы могут включать в себя исполняемый код, библиотеки, открытые файлы или любые другие данные, читаемые из файлов.
  - `RssShmem` - объем физической памяти, который процесс использует для хранения данных в разделяемых областях памяти.
  
- `IO Stats` - информация о вводе/выводе:
  - `rchar` - количество символов, прочитанных из файловой системы
  - `wchar` - количество символов, записанных в файловую систему
  - `syscr` - количество операций чтения
  - `syscw` - количество операций записи
  - `read_bytes` - количество байт, прочитанных из файловой системы
  - `write_bytes` - количество байт, записанных в файловую систему
  - `cancelled_write_bytes` - количество байт, отмененных записей

## buildstats_netstats.patch

В результате, в файлах, формируемых bitbake в процессе сборки, находящихся в директории poky/build/tmp/buildstats/timestamp/recipe/task, появится еще одна строчка следующего вида:
```text
recieve_speed: 437265162.12 B\sec 
```

## pid.patch

Получение и вывод в консоль `pid` процесса вида: `PID: <number>`.

## runqueue.patch

В результате сформируется новый файл poky/build/queue, который будет содержать информацию о задачах из очереди, готовых к выполнению. Вывод следующего формата: timestamp_buildable: {список задач, готовых к выполнению}.

Пример: 
`1720020407.2793891_buildable: {'/home/olga/poky/meta/recipes-devtools/qemu/qemu-native_9.0.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/gcc/libgcc_14.1.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/ptest-runner/ptest-runner_2.4.4.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-graphics/xorg-lib/libxdmcp_1.1.5.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-support/libbsd/libbsd_0.12.2.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-extended/xz/xz_5.4.6.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-devtools/file/file_5.45.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/coreutils/coreutils_9.5.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-build_1.2.1.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-support/libunistring/libunistring_1.2.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/gnutls/libtasn1_4.19.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/libedit/libedit_20240517-3.1.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-more-itertools_10.3.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/cmake/cmake-native_3.29.3.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-graphics/xorg-lib/libxcb_1.17.0.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-support/libmd/libmd_1.1.0.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/gmp/gmp_6.3.0.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-pygments_2.18.0.bb:do_recipe_qa', '
virtual:native:/home/olga/poky/meta/recipes-devtools/autoconf-archive/autoconf-archive_2023.02.20.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/packagegroups/packagegroup-core-boot.bb:do_deploy_source_date_epoch', 
'virtual:native:/home/olga/poky/meta/recipes-core/ncurses/ncurses_6.5.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-extended/grep/grep_3.11.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-extended/pbzip2/pbzip2_1.1.13.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-support/libmicrohttpd/libmicrohttpd_1.0.1.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-extended/libtirpc/libtirpc_1.3.4.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/images/core-image-minimal.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-core/sysvinit/sysvinit-inittab_2.88dsf.bb:do_recipe_qa'}`

*Внимание: вывод обрезан!*

Помимо файла queue сформируется также файл poky/build/skip, который будет содержать информацию о пропущенном запуске задачи (иначе говоря, о тех ситуациях, когда bitbake попробовал запустить задачу, но в итоге ничего не запустил). Данный файл также содержит информацию о времени, когда случилось это событие.

## poky_dir.patch

После начала сборки статистика по каждому рецепту будет находиться в файле `poky/build/recipe_parsing_time.log`. Пример содержимого:
```text
/home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
/home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
/home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
```

Чтобы получить статистику по каждому слою, необходимо запустить файл `poky/create_parsing_info.py`. Полученная статистика
будет находиться в файле `poky/build/layer_parsing_time.log`. Пример содержимого:
```text
meta: 113.22 seconds
meta-poky: 0.03 seconds
```


## cachefiles.patch

Изменение алгоритма опроса зеркал в процессе сверки сигнатур (хэш-значений).

Принцип работы:
В файле index.txt лежат данные о тех файлах, которые находятся на зеркале - пути до них.
Файл index.txt - это индекс-файл, составляющийся автоматически после заполнения sstate-cache в процессе сборки. 
По сути принцип работы с индекс-файлом следующий:
1) Запускаем сборку, чтобы сгенерировать кэш, который впоследствии положим на кэш-сервер. В этот момент генерируется и индекс-файл. Чтобы он сгенерировался, должен быть применен этот патч: https://github.com/moevm/os_profiling/blob/ba530d158b228de3f3bbcff3f738fc559a0afa5b/src/index_developments/diff.txt
2) Кладем всю папку sstate-cache на кэш-сервер вместе с индекс-файлом (он будет внутри папки sstate-cache).
3) При запуске последующих сборок (с настроенной конфигурацией для кэш-сервера) происходят действия, описанные ниже:

После применения патча cachefiles.patch к файлу sstate.bbclass логика опроса зеркал изменяется, и становится следующей:
Происходит итерирование по зеркалам, с каждого зеркала пытаемся получить содержимое файла index.txt, в данный момент в патч добавлена поддержка для http и ftp протоколов. В случае успеха (мы прочитали содержимое этого файла), bitbake определяет, какие задачи из данного списка ему "подходят", и переиспользует их. Если в процессе опроса мы не смогли получить содержимое данного файла с какого-нибудь зеркала (например, потому что на зеркале не было такого файлика, или сервер устроен по другому протоколу, для которого нет поддержки), то тогда данное зеркало будет проверяться по исходному алгоритму bitbake'a.
