# Добавление ежесекундной статистики сети во время сборки

Для добавления ежесекундной статистики сети во время сборки нудно применить патч `add_net_buildstats_instruction.patch`
к файлу `/meta/lib/buildstats.py`. Статистика будет находиться в файле `reduced_proc_net.log` в
папке `build/tmp/buildstats`.