# Добавление графиков со статистикой сети

Для добавления графиков статистики сети нужно поместить патч `add_net_statistics_charts.patch` в папку `poky` и выполнить следующую команду: 

```shell
patch -p1 < add_net_statistics_charts.patch
```
![Пример](https://github.com/moevm/os_profiling/blob/69e10a228f31069f47c84f63c837f029440c88c4/src/yocto-patches/instructions/images/bootchart.png)
