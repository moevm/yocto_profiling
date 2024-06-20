## Статистика нагрузки на сети
Замеры будет производить с помощью утилиты netstat с флагом -i.
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
docker0   1500  1023126      0      0 0       1144117      0      0      0 BMRU
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

