# Как собрать статистику по парсингу рецептов во время сборки

1. Применить патч `cache_py.patch` к файлу `poky/bitbake/lib/bb/cache.py`.
2. Перенести файл `create_parsing_info.py` в папку `poky/build/`.
3. Начать сборку. Статистика по каждому рецепту будет находиться в файле `poky/build/recipe_parsing_time.log`. Пример содержимого:
    ```text
    /home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
    ```
4. Чтобы получить статистику по каждому слою, необходимо запустить файл `create_parsing_info.py`. Полученная статистика
будет находиться в файле `poky/build/layer_parsing_time.log`. Пример содержимого:
    ```text
    meta: 113.22 seconds
    meta-poky: 0.03 seconds
    ```