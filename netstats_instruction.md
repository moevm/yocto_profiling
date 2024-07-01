## Инструкция по применению патча:
1. Переместить патч `buildstats_netstats.patch` в директорию poky/meta/classes-global/.
2. Применить патч: `patch -p1 buildstats.bbclass < buildstats_netstats.patch`
3. Запустить сборку

## Пример результата:
В результате, в файлах, формируемых bitbake в процессе сборки, находящихся в директории poky/build/tmp/buildstats/<timestamp>/<recipe>/<task>, появится еще одна строчка следующего вида:
recieve_speed: 437265162.12 B\sec 
