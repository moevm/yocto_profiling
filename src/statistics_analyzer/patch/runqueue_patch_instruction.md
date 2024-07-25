## Инструкция по применению патча:
1. Переместить патч `runqueue.patch` в директорию poky/bitbake/lib/bb/.
2. Применить патч: `patch -p1 runqueue.py < runqueue.patch`
3. Запустить сборку

## Пример результата:
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

Внимание: вывод обрезан!


Помимо файла queue сформируется также файл poky/build/skip, который будет содержать информацию о пропущенном запуске задачи (иначе говоря, о тех ситуациях, когда bitbake попробовал запустить задачу, но в итоге ничего не запустил). Данный файл также содержит информацию о времени, когда случилось это событие.
