# Сбор информации в форме временных рядов

## Добавление сбора информации в виде временных рядов
1. Переместить патч `buildstats_timestamps.patch` в папку `poky/meta/classes-global/`.
2. Применить патч `buildstats_timestamps.patch` к `poky/meta/classes-global/buildstats.bbclass`:
    ```shell
    patch -p1 buildstats.bbclass < buildstats.patch
    ```
3. Запустить сборку.

## Структура собранной информации
Полученные временные ряды будут находиться в папке `build/tmp/buildstats/{package_name}`. Названия файлов с временными
рядами имеют шаблон `{task_name}_timestamps`.

Пример содержимого файла `{task_name}_timestamps`:
```text
...
Timestamp: 2024-06-25 17:45:13
RAM: VmPeak: 147628 kB, VmSize: 147628 kB, VmHWM: 59252 kB, VmRSS: 59252 kB
IO Stats: rchar: 576639, wchar: 47799, syscr: 53, syscw: 46, read_bytes: 0, write_bytes: 36864, cancelled_write_bytes: 0
...
```
Где 
- `RAM` - информация о потреблении памяти:
  - `VmPeak` - максимальное использование памяти
  - `VmSize` - размер виртуальной памяти
  - `VmHWM` - максимальное использование физической памяти
  - `VmRSS` - размер физической памяти

- `IO Stats` - информация о вводе/выводе:
  - `rchar` - количество символов, прочитанных из файловой системы
  - `wchar` - количество символов, записанных в файловую систему
  - `syscr` - количество операций чтения
  - `syscw` - количество операций записи
  - `read_bytes` - количество байт, прочитанных из файловой системы
  - `write_bytes` - количество байт, записанных в файловую систему
  - `cancelled_write_bytes` - количество байт, отмененных записей
