# Добавление ежесекундной статистики сети во время сборки

Для добавления ежесекундной статистики сети, а также подсчета нагрузки на сеть (и запись в файл `buildstats/net_pressure.log`) во время сборки нужно применить патч `add_net_buildstats_instruction.patch`
к файлу `/meta/lib/buildstats.py`. Статистика будет находиться в файле `reduced_proc_net.log` в
папке `build/tmp/buildstats`.
