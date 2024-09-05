# Добавление графиков со статистикой сети

Для добавления графиков статистики сети нужно поместить патч `add_net_statistics_charts.patch` в папку `poky` и выполнить следующую команду: 

```shell
patch -p1 < add_net_statistics_charts.patch
```
![Пример](https://github.com/moevm/os_profiling/blob/27d6cf6582f82db474fe77a46b3f516fbb3a6933/src/yocto-patches/bootchart.png)
