мини описание патчей

* `add_net_buildstats.patch` добавляет сбор статистики по использованию сети. Сохраняет результаты в файлы `reduced_proc_net.log`, `net_pressure.log` и `current_max_pressure.log` (записывает информацию о нагрузке на сеть в файлы buildstats)
* `add_net_limit.patch` добавляет достижение лимита сети при выборе задачи из очереди (если достигнут лимит, то выбирается *build* задача вместо *fetch*)
* `add_task_children_to_weight.patch` увеличивает приоритет задачам, которые имеют большее количество потомков в графе зависимостей
* `compose_indexfile.patch` после завершения сборки создает index файл в папке с `sstate-cache`
* `poky_dir.patch` измеряет время парсинга рецептов
* `async_filter_with_time.patch` фильтрует асинхронно зеркала + измеряет время
* `runqueue.patch` собирает информацию о том, почмеу конкретная задача не выполняется
* `add_net_statistics_charts.patch` строятся графики по сети (в целом рисует нагрузку на сеть, received, transmitted bytes. изначально на графиках нет ничего про сеть)
* `buildstats_netstat_and_timestamps.patch` что-то устаревшее, скорее всего нигде не используется
* `add_nvme_support.patch` фикс какой-то ошибки с nvme дисками
* `cachefiles.patch` индекс файл

Коммит - 59db27de565fb33f9e4326e76ebd6fa3935557b9, дата - Jan 23 2025