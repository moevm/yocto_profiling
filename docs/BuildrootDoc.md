# **Buildroot**

> Перед началом установки рекомендуется выполнить команду `sudo apt update`. 
> Команда обновляет индекс пакетов в системе Linux или списки пакетов.

- ### **Necessary Packages**
    Как минимум должны быть установлены пакеты `git`, `svn`, и `rsync`. А также всё необходимое для сборки проектов `C`.
    
- ### **Clone buildroot**
    Git был установлен на предыдущем шаге, поэтому выполняем команду в удобной директории:
    ```
    git clone https://github.com/buildroot/buildroot.git buildroot
    ```
    
    После чего необходимо перейти в директорию и создать локальную ветку.
    ```
    cd buildroot
    git checkout -b my-buildroot
    ```
    
- ### **Configuring the Custom Image**
    Все последующие шаги происходят в директории `buildroot`.

    Была выбрана платформа `RaspberryPi3`. Для её инициализации выполняем команду:  
    ```
    make raspberrypi3_defconfig
    ```
    После этого у нас появилась возможность настраивать параметры, пакеты и зависимости образа с помощью команд и соответствующего им интерфейса:
    ```
    make config
    make menuconfig
    make gconfig
    make xconfig
    ```

- ### **Building the Image**
    
    Для запуска сборки необходимо выполнить команду:
    ```
    make
    ```
    
    Результатом сборки является файл `/buildroot/output/images/sdcard.img`
