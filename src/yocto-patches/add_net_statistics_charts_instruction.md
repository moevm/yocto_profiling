# Добавление графиков со статистикой сети

Для добавления графиков статистики сети нужно поместить патч `add_net_statistics_charts.patch` в папку `poky` и выполнить следующую команду: 

```shell
patch -p1 < add_net_statistics_charts.patch
```
![Пример](https://github.com/moevm/os_profiling/blob/add_netstats_chart/netstats_graph/bootchart.png)
