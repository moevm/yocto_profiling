# Параметры для образа

Была взята цель `core-image-minimal` из Yocto.

Используемая версия Yocto - `scarthgap` (5.0), еще не вышла, релиз ожидается в апреле.

Используемая версия Buildroot - `2023.02.9`.

## Базовая конфигурация Yocto

```ShellSession
$ make qemu_x86_64_defconfig
```

## Пакеты

Список пакетов, которые присутствуют в итоговой rootfs:
```
base-files qemux86_64 3.0.14
base-passwd core2_64 3.6.3
busybox core2_64 1.36.1
busybox-hwclock core2_64 1.36.1
busybox-syslog core2_64 1.36.1
busybox-udhcpc core2_64 1.36.1
eudev core2_64 3.2.12
init-ifupdown qemux86_64 1.0
init-system-helpers-service core2_64 1.65.2
initscripts core2_64 1.0
initscripts-functions core2_64 1.0
kernel-6.5.13-yocto-standard qemux86_64 6.5.13+git0+3b1f87ec23_e53dc7514d
kernel-image-6.5.13-yocto-standard qemux86_64 6.5.13+git0+3b1f87ec23_e53dc7514d
kernel-image-bzimage-6.5.13-yocto-standard qemux86_64 6.5.13+git0+3b1f87ec23_e53dc7514d
kernel-module-uvesafb-6.5.13-yocto-standard qemux86_64 6.5.13+git0+3b1f87ec23_e53dc7514d
kmod core2_64 30
ldconfig core2_64 2.38+git0+44f757a636
libblkid1 core2_64 2.39.2
libc6 core2_64 2.38+git0+44f757a636
libcrypto3 core2_64 3.1.4
libkmod2 core2_64 30
liblzma5 core2_64 5.4.4
libz1 core2_64 1.3
modutils-initscripts core2_64 1.0
netbase noarch 6.4
openssl-conf core2_64 3.1.4
openssl-ossl-module-legacy core2_64 3.1.4
packagegroup-core-boot qemux86_64 1.0
sysvinit core2_64 3.04
sysvinit-inittab qemux86_64 2.88dsf
sysvinit-pidof core2_64 3.04
ttyrun core2_64 2.29.0
update-alternatives-opkg core2_64 0.6.2
update-rc.d noarch 0.8
v86d qemux86_64 0.1.10
```

## Конфигурация ядра

TODO
