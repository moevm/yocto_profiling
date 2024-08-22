# Как собрать статистику по парсингу рецептов во время сборки

1. Переместить патч `poky_dir.patch` в директорию `poky/`. Применить патч `poky_dir.patch` к директории `poky/`:
   находясь в директории `poky/`, выполнить команду:
   ```shell
   patch -p1 < poky_dir.patch
   ```
2. Начать сборку. Статистика по каждому рецепту будет находиться в файле `poky/build/recipe_parsing_time.log`. Пример содержимого:
    ```text
    /home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
    /home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
    ```
3. Чтобы получить статистику по каждому слою, необходимо запустить файл `poky/create_parsing_info.py`. Полученная статистика
будет находиться в файле `poky/build/layer_parsing_time.log`. Пример содержимого:
    ```text
    meta: 113.22 seconds
    meta-poky: 0.03 seconds
    ```