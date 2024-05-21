# Запуск парсера
Запуск любой программы, использующей внутри себя сбор статистики при помощи парсера должен происходить следующим образом:
`
python3 ./<name>.py --poky <путь до папки poky> -b <индекс сборки>
`
или
`
python3 ./<name>.py --poky <путь до папки poky> -t <конкретный timestamp>
`

## Использование парсера и запуск ранжирования

Для начала необходимо получить информацию о существующих сборках и получить отсортированный по timestamp'ам список сборок:
`

    args = create_parser_args()
    timestamp = ''
    timestamp_list = []
    poky_buildstats_path = os.path.join(args.poky_path, 'build/tmp/buildstats')
    tree = list(os.walk(poky_buildstats_path))
    for item in tree:
        if item[0] == poky_buildstats_path:
            timestamp_list = item[1]
    timestamp_list.sort(reverse=True)

    if args.timestamp is None and args.build_index is None:
        print('No timestamp or build index specified')
        return
    elif args.timestamp is not None and args.build_index is not None:
        print("Specify only timestamp or only build index")
        return
    if args.timestamp:
        if args.timestamp in timestamp_list:
            timestamp = args.timestamp
        else:
            print('No such timestamp')
            return
    else:
        if len(timestamp_list) > args.build_index:
            timestamp = timestamp_list[args.build_index]
        else:
            print('No such build index')
            return


Далее необходимо создать объект класса Parser и запустить сбор статистики:
`   

    parser = Parser(args.poky_path)
    parser.get_data_from_buildstats(os.path.join(args.poky_path, 'build/tmp/buildstats', timestamp))



После этого можно использовать статистику с разными целями, например:

Записать в файлы:

    parser.write_data_about_all_packages()
    for task_type in all_tasks:
        parser.write_data_about_task(task_type)



Отранжировать и записать в файл:

В данном примере в файл ranking_output.txt записывается 10% самых долгих по выполнению (метрика 'Elapsed time' выставлена по умолчанию) задач

    data = get_ranked_data_for_all_tasks(parser.info, parser.pid_info, border=0.1)
    write_ranked_data(data, 'ranking_output.txt')

В данном примере отранжируем по метрике Started все задачи и запишем их в файл в порядке возрастания:

    data = get_ranked_data_for_all_tasks(parser.info, parser.pid_info, metric='Started', border=1, reverse=False)
    write_ranked_data(data, 'ranking_output.txt')

