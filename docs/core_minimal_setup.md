## Sequencing - последовательность действий во время сборки образа 
Образ ставился по инструкции https://tutorialadda.com/yocto/quick-start-your-first-yocto-project-build
- [x] 1) Установка библиотек и зависимостей
- [x] 2) Клонирование репозитрия и выбор ветки
- [X] 3) Сборка образа
- [X] 4) Запуск qemu
### Шаг 1 - установка библиотек и зависимостей
С помощью команды установлены библиотеки: `sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm`

### Шаг 2 - Клонирование репозитрия 
С помощью команды склонирован репозиторий: `git clone git://git.yoctoproject.org/poky` -- остаемся на ветке master


### Шаг 3 - Сборка образа
#### Создание окружения 
С помощью команды создано окружение: `source oe-init-build-env`
#### Сборка образа 
С помощью команды собран минимальный образ :`bitbake core-image-minimal`  
Во время сборки образа произошла ошибка сборки openssl - при повторном введение команды ошибка самоликвидировалась

### Шаг 4 - Запуск qemu
#### Попытка запуска qemu
С помощью команды произведена попытка запуска qemu : `runqemu qemux86-64`

Загрузка очень долгая
![image](https://github.com/moevm/os_profiling/assets/90711883/70b5d0ff-d73b-45c5-8ef4-50d42bbed127)


При нажатии на Enter появляются надписи:
![image](https://github.com/moevm/os_profiling/assets/90711883/13347208-3425-4b95-93d7-56b84a7e15d6)


Нажа много раз на Enter - удалось войти в систему
![image](https://github.com/moevm/os_profiling/assets/90711883/69e2aee7-8c14-4e34-bacf-c8fc1049361e)
