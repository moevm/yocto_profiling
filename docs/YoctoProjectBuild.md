# **Yocto Project Quick Build**

> Перед началом установки рекомендуется выполнить команду `sudo apt update`. 
> Команда обновляет индекс пакетов в системе Linux или списки пакетов.

- ### **Build Host Packages**
    Для установки необходимых пакетов необходимо выполнить команду:
    ``` 
    sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales libacl1 
    ```
    
    После выполнения данной команды может появиться ошибка, связанная с невозможностью поиска пакета **libegl1-mesa**. В данном случае рекомендуется установить зависимость самостоятельно, [ссылка на скачивание](https://launchpad.net/ubuntu/+archive/primary/+files/libegl1-mesa_23.0.4-0ubuntu1%7E22.04.1_amd64.deb).
   
   Далее необходимо сгенерировать локаль:
    ``` 
    sudo locale-gen en_US.UTF-8 
    ```
    
- ### **Clone Poky**
    Git был установлен на предыдущем шаге, поэтому выполняем команду в удобной директории:
    ```
    git clone git://git.yoctoproject.org/poky
    ```
    
    После чего необходимо перейти в директорию и создать локальную ветку.
    ```
    cd poky
    git checkout -t origin/nanbield -b my-nanbield
    ```
    
- ### **Building Your Image**
    Все последующие шаги происходят в директории `poky`.

    **Initialize the Build Environment:**
    ```
    source oe-init-build-env
    ```
    Logs:
    ```
    ### Shell environment set up for builds. ###

    You can now run 'bitbake <target>'
    
    Common targets are:
        core-image-minimal
        core-image-full-cmdline
        core-image-sato
        core-image-weston
        meta-toolchain
        meta-ide-support
    
    You can also run generated QEMU images with a command like 'runqemu qemux86-64'
    
    Other commonly useful commands are:
     - 'devtool' and 'recipetool' handle common recipe tasks
     - 'bitbake-layers' handles common layer tasks
     - 'oe-pkgdata-util' handles common target package tasks
    ```
    
    **Start the Build:**
    Среди предложенных был выбран `core-image-sato`. Для начала сборки образа выполним команду:
    ```
    bitbake core-image-sato
    ```
    Logs:
    ```
    WARNING: Host distribution "ubuntu-23.10" has not been validated with this version of the build system; you may possibly experience unexpected failures. It is recommended that you use a tested distribution.
    Loading cache: 100% |######################################################| Time: 0:00:00
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
    meta-yocto-bsp       = "my-nanbield:6d6ccbca0ce6b145224fa94d3c62a45e453c969f"
    
    Initialising tasks: 100% |#################################################| Time: 0:00:02
    Sstate summary: Wanted 1 Local 0 Mirrors 0 Missed 1 Current 4330 (0% match, 99% complete)
    NOTE: Executing Tasks
    NOTE: Tasks Summary: Attempted 8782 tasks of which 8782 didn't need to be rerun and all succeeded.
    
    Summary: There was 1 WARNING message.
    ```
    Так как образ уже был собран до запуска этой команды, то логи существенно сократились. Это можно понять по строке: `NOTE: Tasks Summary: Attempted 8782 tasks of which 8782 didn't need to be rerun and all succeeded.
    `.
    
    **Simulate Your Image Using QEMU:**
    Для запуска симуляции собранного образа необходимо выполнить команду:
    ```
    runqemu qemux86-64
    ```
    Logs:
    ```
    runqemu - INFO - Running MACHINE=qemux86-64 bitbake -e  ...
    runqemu - INFO - Continuing with the following parameters:
    KERNEL: [/home/egorbutylo/workSpace/poky/build/tmp/deploy/images/qemux86-64/bzImage]
    MACHINE: [qemux86-64]
    FSTYPE: [ext4]
    ROOTFS: [/home/egorbutylo/workSpace/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240207182205.ext4]
    CONFFILE: [/home/egorbutylo/workSpace/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240207182205.qemuboot.conf]
    
    runqemu - INFO - Setting up tap interface under sudo
    [sudo] password for egorbutylo: 
    runqemu - INFO - Network configuration: ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0
    runqemu - INFO - Running /home/egorbutylo/workSpace/poky/build/tmp/work/x86_64-linux/qemu-helper-native/1.0/recipe-sysroot-native/usr/bin/qemu-system-x86_64 -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:02 -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0 -drive file=/home/egorbutylo/workSpace/poky/build/tmp/deploy/images/qemux86-64/core-image-sato-qemux86-64.rootfs-20240207182205.ext4,if=virtio,format=raw -usb -device usb-tablet -usb -device usb-kbd   -cpu IvyBridge -machine q35,i8042=off -smp 4 -m 512 -serial mon:vc -serial null -device virtio-vga  -display sdl,show-cursor=on  -kernel /home/egorbutylo/workSpace/poky/build/tmp/deploy/images/qemux86-64/bzImage -append 'root=/dev/vda rw  ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0 oprofile.timer=1 tsc=reliable no_timer_check rcupdate.rcu_expedited=1 swiotlb=0 '

    runqemu - INFO - Host uptime: 3771.17
    ```
    ![](https://github.com/moevm/os_profiling/blob/butylo-docs/docs/YoctoProjectView.png)
    
    Для того, чтобы выйти, необходимо нажать на иконку `shutdown` либо использовать сочетание клавиш `Ctrl + C` в терминале, который использовался для запуска образа.
    Logs:
    ```
    runqemu - INFO - Cleaning up
    runqemu - INFO - Host uptime: 3884.36
    ```
