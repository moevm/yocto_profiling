### Buildroot setup sequencing

- [x] 1) Установка репозитория buildroot
- [x] 2) Создание qemu конфигурации
- [X] 3) Сборка образа
- [X] 4) Запуск qemu
### Шаг 1 - Установка репозитория buildroot
С помощью команды клонирован репозитрий buildroot: `git clone git://git.busybox.net/buildroot` -- остаемся на ветке master

### Шаг 2 - Клонирование репозитрия 
С помощью команды создана qemu конфигурация: `make qemu_x86_def_config` 


### Шаг 3 - Сборка образа
С помощью команды собран образ :`make`  
Сборка завершилась корректно (как я понял)

### Шаг 4 - Запуск qemu
#### Попытка запуска qemu
С помощью команды произведена попытка запуска qemu : `.../output/images$ ./start-qemu.sh`

Получилось зайти:  
![image](https://github.com/moevm/os_profiling/assets/90711883/8a0abd07-f125-441e-805d-a2b0dd299c67)

