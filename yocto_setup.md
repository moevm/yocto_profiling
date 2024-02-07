# Создание базового образа системы с помощью Yocto Project

### 1. Установка необходимых пакетов
Для установки необходимых пакетов необходимо было выполнить следующую команду
```
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales libacl1

```
Поскольку при выполнении данной команды возникла ошибка **Невозможно найти пакет libegl1-mesa**, пакет libegl1-mesa был скачан вручную и далее была выполнена команда
```
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 ./libegl1-mesa.deb libsdl1.2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales libacl1
```
и
```
sudo locale-gen en_US.UTF-8
```
### 2. Клонирование Poky репозитория
Затем с помощью команды
```
git clone git://git.yoctoproject.org/poky
```
был склонирован репозиторий с Poky.
Была создана ветка my-nanbield
```
$ git branch
  master
* my-nanbield
```
### 3. Сборка образа
Инициализация среды сборки проводилась с помощью команды
```
$ cd poky
$ source oe-init-build-env

### Shell environment set up for builds. ###

You can now run 'bitbake <target>'

Common targets are:
    core-image-minimal
    core-image-full-cmdline
    core-image-sato
    core-image-weston
    meta-toolchain
    meta-ide-support

You can also run generated qemu images with a command like 'runqemu qemux86-64'.

Other commonly useful commands are:
 - 'devtool' and 'recipetool' handle common recipe tasks
 - 'bitbake-layers' handles common layer tasks
 - 'oe-pkgdata-util' handles common target package tasks
```
Для сборки образа использовалась команда
```
$ bitbake core-image-sato
WARNING: Host distribution "ubuntu-23.10" has not been validated with this version of the build system; you may possibly experience unexpected failures. It is recommended that you use a tested distribution.
Loading cache: 100% |############################################| Time: 0:00:00
Loaded 1845 entries from dependency cache.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.6.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "4.3.2"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta                 
meta-poky            
meta-yocto-bsp       = "my-nanbield:cf9b37dfd05672f2df77686029fdfbf218fc71e4"

Initialising tasks: 100% |#######################################| Time: 0:00:02
Sstate summary: Wanted 2605 Local 0 Mirrors 0 Missed 2605 Current 1726 (0% match, 39% complete)
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 8782 tasks of which 4987 didn't need to be rerun and all succeeded.

Summary: There was 1 WARNING message.
```
### 4. Запуск образа с помощью QEMU
Запуск образа
```
$ runqemu qemux86-64
runqemu - INFO - Running MACHINE=qemux86-64 bitbake -e  ...
runqemu - INFO - Continuing with the following parameters:
KERNEL: [/home/elizaveta/poky/build/tmp/deploy/images/qemux86-64/bzImage]
MACHINE: [qemux86-64]
FSTYPE: [ext4]
ROOTFS: [/home/elizaveta/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240206140622.ext4]
CONFFILE: [/home/elizaveta/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240206140622.qemuboot.conf]

runqemu - INFO - Setting up tap interface under sudo
[sudo] пароль для elizaveta: 
runqemu - INFO - Network configuration: ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0
runqemu - INFO - Running /home/elizaveta/poky/build/tmp/work/x86_64-linux/qemu-helper-native/1.0/recipe-sysroot-native/usr/bin/qemu-system-x86_64 -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:02 -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 -drive file=/home/elizaveta/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240206140622.ext4,if=virtio,format=raw -usb -device usb-tablet -usb -device usb-kbd   -cpu IvyBridge -machine q35,i8042=off -smp 4 -m 512 -serial mon:vc -serial null -device virtio-vga  -display sdl,show-cursor=on  -kernel /home/elizaveta/poky/build/tmp/deploy/images/qemux86-64/bzImage -append 'root=/dev/vda rw  ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0 oprofile.timer=1 tsc=reliable no_timer_check rcupdate.rcu_expedited=1 swiotlb=0 '

runqemu - INFO - Host uptime: 2576.12

runqemu - INFO - Cleaning up
runqemu - INFO - Host uptime: 2673.65
```
![](https://github.com/moevm/os_profiling/blob/2118aa45b8627891556b2beb58235fb37c05d46d/yocto.png)
