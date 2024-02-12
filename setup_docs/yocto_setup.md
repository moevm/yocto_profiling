## Создание базового образа

Были выполнены шаги в соответсвии с документацией: https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html

## 1. Установка пакетов
Необходимые пакеты уже были установлены на хосте

## 2. Клонирование репозитория
Был склонирован репозиторий https://github.com/yoctoproject/poky

## 3. Инициализация среды
При помощи команды `$ source oe-init-build-env` была проинициализирована среда сборки

## 4. Сборка образа
Для запуска сборки использовалась команда `$ bitbake -v core-image-sato`
Сборка прошла успешно без ошибок.

## 5. Запуск в эмуляторе qemu

Была произведена попытка запуска при помощи команды `$ runqemu qemux86-64`, но запуск не удался, так как производился с ПК в лабораторной, и без доступа к sudo не сработал.

Проблема была решена следующим образом: использовалась команда `$/home/user/dok/poky/build/tmp/work/x86_64-linux/qemu-helper-native/1.0/recipe-sysroot-native/usr/bin/qemu-system-x86_64 -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 -drive file=/home/user/dok/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240212085739.ext4,if=virtio,format=raw -usb -device usb-tablet -usb -device usb-kbd   -cpu IvyBridge -machine q35,i8042=off -smp 4 -m 512 -serial mon:stdio -serial null -nographic  -kernel /home/user/dok/poky/build/tmp/deploy/images/qemux86-64/bzImage -append 'root=/dev/vda rw  ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0 console=ttyS0 console=ttyS1 oprofile.timer=1 tsc=reliable no_timer_check rcupdate.rcu_expedited=1 swiotlb=0 '`

Был произведен запуск: 
![alt text](image-1.png)


