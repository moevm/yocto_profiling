# Добавление предела нагрузки на сеть во время сборки

Для ускорения сборки пакетов в Yocto Project, можно добавить предел нагрузки на сеть во время сборки. Для этого нужно
сначала применить
патч [add_net_buildstats.patch](https://github.com/moevm/os_profiling/blob/1aa71b1f78111d2f731c0d86d5c1c60c3e091860/src/yocto-patches/add_net_buildstats.patch),
затем патч `add_net_limit.patch`.