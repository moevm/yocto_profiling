## Инструкция по проведению эксперимента
Для проведения эксперимента необходимо:
1. Скопировать папку `meta-user` в папку `poky`.
2. В файл `poky/build/conf/bblayers.conf` в `BBLAYERS` добавить путь к папке `meta-user`. Пример:  
```
BBLAYERS ?= " \
  /home/user/poky/meta \
  /home/user/poky/meta-poky \
  /home/user/poky/meta-yocto-bsp \
  /home/user/poky/meta-user \
  "
```
3. В рецепт `poky/meta/recipes-core/images/core-image-minimal.bb` (может быть другой, в зависимости от образа, который хотим собрать), добавить строку 
```
IMAGE_INSTALL += " helloworld"
```
4. Удалить папку `/poky/build/downloads`
5. Запустить сборку
6. В рецепт `json.bb` добавить строку 
```
SRC_URI += "file://changes.patch"
```
7. Удалить папку `/poky/build/downloads`
8. Запустить сборку
