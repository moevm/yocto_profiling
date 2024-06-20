## Статистика нагрузки на сети
Замеры будет производить с помощью утилиты netstat с флагом -i.  
1) Параметры - Хэш и Кэш сервера разнесены по разным пк  
2) Количество серверов для Кэша - 10.
### До начала сборки
```
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
br-dffff  1500        0      0      0 0             0      0      0      0 BMU
br-f1b1f  1500        0      0      0 0             0      0      0      0 BMU
docker0   1500       93      0      0 0           181      0      0      0 BMRU
enp5s0    1500    60341      0      0 0         36530      0      0      0 BMRU
lo       65536     1990      0      0 0          1990      0      0      0 LRU
veth03e6  1500        0      0      0 0           117      0      0      0 BMRU
veth09b0  1500        0      0      0 0           117      0      0      0 BMRU
veth28b5  1500        0      0      0 0           116      0      0      0 BMRU
veth4697  1500        0      0      0 0           118      0      0      0 BMRU
veth4b6c  1500        0      0      0 0           117      0      0      0 BMRU
veth7eef  1500       93      0      0 0           214      0      0      0 BMRU
veth822a  1500        0      0      0 0           111      0      0      0 BMRU
vetha0a7  1500        0      0      0 0           117      0      0      0 BMRU
vethf38e  1500        0      0      0 0           117      0      0      0 BMRU
vethf4f2  1500        0      0      0 0           118      0      0      0 BMRU
```

### После Парсинга до основной сборки
```
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
br-dffff  1500        0      0      0 0             0      0      0      0 BMU
br-f1b1f  1500        0      0      0 0             0      0      0      0 BMU
docker0   1500   116521      0      0 0        124177      0      0      0 BMRU
enp5s0    1500   184990      0      0 0        162516      0      0      0 BMRU
lo       65536     2034      0      0 0          2034      0      0      0 LRU
veth03e6  1500    13907      0      0 0         14497      0      0      0 BMRU
veth09b0  1500     6251      0      0 0          6639      0      0      0 BMRU
veth28b5  1500     1662      0      0 0          1853      0      0      0 BMRU
veth4697  1500    17038      0      0 0         18695      0      0      0 BMRU
veth4b6c  1500    12893      0      0 0         14148      0      0      0 BMRU
veth7eef  1500    18951      0      0 0         19846      0      0      0 BMRU
veth822a  1500      750      0      0 0           923      0      0      0 BMRU
vetha0a7  1500    11353      0      0 0         11841      0      0      0 BMRU
vethf38e  1500    15928      0      0 0         18242      0      0      0 BMRU
vethf4f2  1500    17788      0      0 0         18727      0      0      0 BMRU
```

### Когда процесс завершился

```
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
br-dffff  1500        0      0      0 0             0      0      0      0 BMU
br-f1b1f  1500        0      0      0 0             0      0      0      0 BMU
docker0   1500  1023126      0      0 0       1144117      0      0      0 BMRU![tx](https://github.com/moevm/os_profiling/assets/90711883/39943766-ed6a-4df2-b71f-6976d65e4f0a)

enp5s0    1500  1206134      0      0 0       1876950      0      0      0 BMRU
lo       65536     2091      0      0 0          2091      0      0      0 LRU
veth03e6  1500   191000      0      0 0        206586      0      0      0 BMRU
veth09b0  1500   287078      0      0 0        348438      0      0      0 BMRU
veth28b5  1500   102271      0      0 0        101303      0      0      0 BMRU
veth4697  1500    57710      0      0 0         66806      0      0      0 BMRU
veth4b6c  1500    56856      0      0 0         64708      0      0      0 BMRU
veth7eef  1500    79611      0      0 0         86478      0      0      0 BMRU
veth822a  1500     6811      0      0 0          8057      0      0      0 BMRU
vetha0a7  1500   117486      0      0 0        122671      0      0      0 BMRU
vethf38e  1500    64300      0      0 0         73303      0      0      0 BMRU
vethf4f2  1500    60003      0      0 0         67100      0      0      0 BMRU
```
## Графики
По полученным данным построены графики:
### RX
#### RX exp
![rx_exp](https://github.com/moevm/os_profiling/assets/90711883/1e18b051-e0de-40ae-be84-3c2153ef60a0)

#### RX linear
![rx_linear](https://github.com/moevm/os_profiling/assets/90711883/6adb4910-6e15-4d2d-bb02-a70636ab97b9)
### TX
#### TX exp
![tx_exp](https://github.com/moevm/os_profiling/assets/90711883/2e3860f1-7f9e-453d-8e10-ecffbbcc8183)

#### TX linear
![tx_linear](https://github.com/moevm/os_profiling/assets/90711883/a2b585ac-ee56-4a61-8b6b-dfeb2c210b4a)

### Выводы
По графикам exp видно, что сумма интерфейсов `veth*` почти сходится к `docker0`, потому `docker0` почти не видно.   
По графикам linear видно, что во время сборки нагрузка на сеть кэш сервера больше, чем во время парсинга рецептов.

По таблицам netstat видно, что некоторый интерфейсы используются значительно реже других, а некоторые наоборот - часто. Дело в том, что кэш распределен по серверам неравномерно по объему, это приводит к тому, что сервера, на которых больше кэша, потребляются больше ресурсов сети. Потому не было смысла строить график по каждому интерфейсу - это показало бы лишь то, насколько равномерно или неравномерно по объему мы распределили кэш.

