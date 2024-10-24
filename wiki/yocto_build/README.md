# Сборка Yocto
В данной папке находится информация, связанная с различными аспектами сборки Yocto.
* [yocto_system_image_build](./yocto_system_image_build.md) - описание некоторых аспектов сборки Yocto: где, как и когда в итоговый образ добавляются файлы, отличия слоев и классов
* [image_deps](./image_deps.md) - список параметров для образа core-image-minimal (список пакетов, конфигурация ядра)
* [add_layers](./add_layers.md) - описание добавления слоев

## Внутреннее устройство сборки Yocto

* [yocto_build_deps](./yocto_build_deps.md) - как BitBake обрабатывает зависимости, описание процесса парсинга рецептов
* [yocto_stat_sources](./yocto_stat_sources.md) - как Yocto собирает статистику
* [task_map](./task_map.md) - описание процесса создания собственного рецепта
* [directories_sizes](./directories_sizes.md) - описание содержимого дискового пространства в папке build
* [WORKDIR](./WORKDIR.md) - получение переменной WORKDIR для рецепта
* [tasks_priority](./tasks_priority.md) - как и где устанавливается приоритет задач, эксперимент по изменению приоритетов задач do_compile и do_configure

## Собираемая статистика в Yocto
* [logging_build](./loging_building.md) - инструкция по логированию в Yocto (как сохранить лог)
* [yocto_buildstats](./yocto_buildstats.md) - анализ статистики сборки
* [pid-info](./pid-info.md) - описание логирования PID
* [bitbake_pressure_variables](./bitbake_pressure_variables.md) - описание переменных нагрузки Bitbake и описание процесса мониторинга свободного места 
