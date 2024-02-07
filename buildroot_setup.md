# Создание базового образа системы с помощью Buildroot

### 1. Клонирование bulidroot репозитория
Был склонирован репозиторий
```
git clone https://github.com/buildroot/buildroot.git buildroot
```
и создана ветка
```
git checkout -b my-buildroot
```
### 2. Настройка пользовательского образа
В данном случае будет создаваться образ для RaspberryPi3, для этого необходимо выполнить следующую команду
```
make raspberrypi3_defconfig
```
После выполнения эта команда создаст файл .config, который содержит все пакеты, ядро, набор инструментов и свойства, необходимые для нашего образа. Чтобы добавить новые пакеты или отредактировать существующие, нужно изменить этот файл. Для этого можно ввести команду
```
make menuconfig
```
Нам открывается меню, в котором можно изменять различные настройки
![](https://github.com/moevm/os_profiling/blob/2118aa45b8627891556b2beb58235fb37c05d46d/buildroot.png)

### 3. Сборка образа
Сборка осуществляется с помощью простой команды
```
make
```
После сборки результат можно найти в папке **output/images**
```
$ cd output/images/
$ ls
bcm2710-rpi-3-b.dtb       boot.vfat     rootfs.ext4   sdcard.img
bcm2710-rpi-3-b-plus.dtb  genimage.cfg  rootfs.tar    zImage
bcm2710-rpi-cm3.dtb       rootfs.ext2   rpi-firmware
```

