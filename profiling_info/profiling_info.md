# Что собирает какую информацию

## Найденные готовые решения

* Трассировка с помощью ftrace: [cpu_tracer](../wiki/yocto_profiling_tools/cpu_tracer.md)
  - Собирает информацию о выполнении процессов на уровне ядра, трассировку событий, которые происходят в системе.

* Различные утилиты для профилирования: [profiling_tools](../wiki/yocto_profiling_tools/profilling_tools.md)
  - perf: собирает информацию о производительности системы.
  - perf stat: собирает статистику производительности.
  - perf mem: собирает информацию о доступе к памяти.
  - iostat: собирает статистику ввода-вывода.
  - lsof: показывает открытые файлы и сокеты.
  - Strace: трассирует системные вызовы.

* Профилирование процессов с помощью [psutil](../wiki/yocto_profiling_tools/psutil_lsof.md):
  - `psutil.Process.open_files()`: возвращает список открытых файлов для указанного процесса.
  - `psutil.Process.connections()`: возвращает список всех сетевых соединений для указанного процесса.
  - `process.memory_maps()`: получение информации об отображенных в память файлах для указанного процесса.

  - Как можно анализировать: анализ списка открытых файлов для выявления возможных узких мест и ресурсозатратных операций, подсчет количества сетевых соединений для определения нагрузки на сеть.

* Статистика сборки ([buildstats](../wiki/yocto_build/yocto_buildstats.md)):
  - Собирает:
    - Информацию о хост-системе [build_stats.txt](log_files/build_stats.txt).
    - Среднюю загрузку процессора [cpu.log](log_files/cpu.log).
    - Статистику диска [monitor_disk.log](log_files/monitor_disk.log).
    - Статистику IO [io.log](log_files/io.log).
    - Информацию об использовании памяти [memory.log](log_files/memory.log).
    - Данные о начале, конце выполнения и статусе задач (do_configure, do_install, do_compile и др.).
  Пример файла содержащего статистику одной задачи - [do_fetch](log_files/do_fetch.txt)
  Пример файла содержащего временные ряды для одной задачи - [do_fetch_timestamps](log_files/do_fetch_timestamps.txt)
    
    - Как можно анализировать: можно рассчитать среднюю нагрузку на диск, IO, память, CPU, а также выявить наиболее ресурсоемкие задачи.

## Разработанные нами решения

* Ранжирование самых нагруженных задач: [launch](../wiki/yocto_profiling_tools/launch.md)
  - Собирает информацию о наиболее ресурсоемких задачах.

* Построение и анализ графа зависимостей: [launch](../wiki/yocto_profiling_tools/launch.md)
  - Собирает:
    - Сортировку вершин графа - [пример файла](log_files/tasks-order.txt).
    - Нахождение оффсета между концом выполнения дочерней вершины и началом выполнения родительской вершины и сортировка вершин графа по этому оффсету - [пример файла](log_files/task-order-sorted-offset.txt).
    - Нахождение "корня".
    - Проверку на древовидную структуру.
    - Визуализацию слоев графа.

* Сбор информации об IO и RAM в виде временных рядов: [buildstats_timestamps](https://github.com/moevm/os_profiling/blob/77b1476f8f5d8eb507c7887274aafdd615f64891/build/buildstats_timestamps/buildstats.patch)
    - Пример полученной информации:
      ```
      Timestamp: 2024-06-25 17:45:13
      RAM: VmPeak: 147628 kB, VmSize: 147628 kB, VmHWM: 59252 kB, VmRSS: 59252 kB
      IO Stats: rchar: 576639, wchar: 47799, syscr: 53, syscw: 46, read_bytes: 0, write_bytes: 36864, cancelled_write_bytes: 0
      ```
    - Как можно анализировать: можно выявлять пики, определять наиболее загруженные моменты, визуализировать для наглядности данные.

* Время парсинга рецептов из различных слоев: [parsing_statistics](https://github.com/moevm/os_profiling/blob/b65661fd3477a63ae9cf38e917ba3cdaf1662bd0/build/parsing_statistics/poky_dir.patch)
    - Пример результата ([файл](log_files/layer_parsing_time.log)):
      ```
      meta: 113.22 seconds
      meta-poky: 0.03 seconds
      ```
    - Как можно анализировать: можно выявлять слои, которые требуют наибольшего времени на парсинг, и слои с минимальным временем парсинга.

* Время парсинга каждого рецепта: [parsing_statistics](https://github.com/moevm/os_profiling/blob/b65661fd3477a63ae9cf38e917ba3cdaf1662bd0/build/parsing_statistics/poky_dir.patch)
    - Пример результата ([файл](log_files/recipe_parsing_time.log)):
      ```
      /home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
      /home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
      /home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
      ```
    - Как можно анализировать: можно выявлять рецепты, которые требуют наибольшего времени на парсинг, и рецепты с минимальным временем парсинга.


* Сопоставление информации о ресурсах к пакету: [packages_charts](../src/packages-charts/packages_charts.md)
  - Собирает информацию о том, сколько ресурсов понадобилась определенному пакету.
  - Как можно анализировать: визуализация (уже сделано), определение пакетов с наибольшим потреблением ресурсов для дальнейшей оптимизации.