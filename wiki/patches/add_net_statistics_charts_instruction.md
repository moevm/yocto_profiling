# Добавление графиков со статистикой сети

Для добавления графиков статистики сети нужно поместить патч `add_net_statistics_charts.patch` в папку `poky` и выполнить следующую команду: 

```shell
patch -p1 < add_net_statistics_charts.patch
```
![Пример](https://github.com/moevm/os_profiling/blob/677b66e07747cf31ec0b049d50f22f7ed68b0222/wiki/patches/images/bootchart.png)
