# Инструкция по запуску и проведению эксперимента speed_up

> [!WARNING]
> Инструкция актуальна для запуск из лаборатории (здесь настроены proxy). Чтобы запустить локально, нужно убрать из `os_profiling/src/yocto-build/assembly/scripts/building.sh` строки 24-26 с настройкаой proxy.

1. Клонирование  
Клонировать текущий репозиторий и перейти на ветку `speeding_up_exp`

SSH:
```bash
git clone git@github.com:moevm/os_profiling.git -b speeding_up_exp
```
или  

HTTPS:
```bash
git clone https://github.com/moevm/os_profiling.git -b speeding_up_exp
```

2. Запуск  
Перейти в папку `os_profiling/src/common/scripts`
+ Если хоим запустить полный эксперимент:
```bash
nohup ./speeding_up_experiment.sh <количество повторений> &
```
+ Если хотим запустить патч с сейтью:
```bash
nohup ./speeding_up_experiment_net.sh <количество повторений> &
```
+ Если хотим запустить патч с детьми:
```bash
nohup ./speeding_up_experiment_childrens.sh <количество повторений> &
```

3. Сбор данных  
В папке `os_profiling/src/common/scripts` появится файл nohup.out там много строк, если хотим узнать успешна ли прошла сборка \ сборки, то с помщью `cat nohup.out -n | grep "Yocto building ends with code"` можно проверить был ли код возврата отличный от 0.

В папке `os_profiling/src/buildstats_saves` находятся полные логи bitbake + файл time.txt, в котором указано время


4. Анализ данных  
Для анализа полученных данных в time.txt нужно воспользовать скриптом из этого PR https://github.com/moevm/os_profiling/pull/323  
С помощью парсера указать путь к четырем файлам time.txt, в которых будут результаты без патча, с каждым патчем по отдельности и со всеми патчами.



