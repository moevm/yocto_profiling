# Инструкция по обработке логов read/write статистики
1. Для получения логов read/write статистики необходимо запустить сборку с помощью команды 
    ```bash
    strace -f -e trace=read,write,readv,writev -o yocto_trace_all.log bitbake core-image-minimal
    ```
2. Также для получения статистики по read/write нужен файл содержащий список задач с их pid. Для этого достаточно запустить ранжирование по [`инструкции`](../statistics_analyzer/README.md). В результате будет получен файл `ranking_output.txt`
3. Далее необходимо обработать логи с помощью скрипта `process_logs.py`:
    ```bash
    python3 process_logs.py -l <путь до yocto_trace_all.log> -t <путь до ranking_output.txt>
    ```
4. После выполнения скрипта в папке `read_write_statistics/output` появятся файлы `process_statistics_rw.txt` и `process_statistics_rwv.txt`, содержащие статистику по read/write и readv/writev операциям
