## Содержимое директории /poky/build/cache

В документации Yocto указано, что директория /poky/build/cache содержит внутренние файлы, которая использует система сборки.

Из важного, директория /poky/build/cache содержит текстовый файл sanity_info, в котором находится информация, такая как значения TMPDIR, SSTATE_DIR, а также название и версия дистрибутива хоста.

Также содержит файл bb_persist_data.sqlite3, который является централизованным хранилищем данных, к которым в будущем могут обратиться другие потоки/задачи.

Ссылка на документацию yocto: https://docs.yoctoproject.org/ref-manual/structure.html
Ссылка на файл исходного кода с комментариями: https://github.com/openembedded/bitbake/blob/97ffe14311407f6e705ec24b70870ab32f0637b9/lib/bb/persist_data.py#L241
