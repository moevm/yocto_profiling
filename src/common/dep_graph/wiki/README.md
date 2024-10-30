## Использование программы для сортировки вершин графа и нахождения оффсетов

Для начала необходимо запустить парсер и сбор статистики (запуск парсера и сбора статистики описан здесь: https://github.com/moevm/os_profiling/blob/denisova_olga_parsing_ranking/statistics_analyzer/README.md)

Также перед анализом графа зависимостей необходимо создать файл task-depends.dot (создание данного файла и визуализация графа описана здесь: https://github.com/moevm/os_profiling/blob/denisova_olga_dep_graph/dep_graph/wiki/dep_graph.md)

Затем можно создать объект графа и анализировать его:

    G = nx.DiGraph(nx.nx_pydot.read_dot('./task-depends.dot'))
    sorted_tasks = sort_start_time(parser.info)
    sorted_nodes = []
    for node in G.nodes: #для каждой вершины найти соответствующий ей индекс в sorted_tasks
        index, start, end = match(node, sorted_tasks)
        sorted_nodes.append((index, node, start, end))

    sorted_nodes = sorted(sorted_nodes, key=lambda x:x[0])
    #write(sorted_nodes, 'tasks-order.txt') #можно записать задачи в файл в порядке старта их выполнения

В примере выше происходит сопоставление вершин графа и объектов из статистики, и вершины нумеруются в порядке старта их выполнения.


Для каждой вершины можно найти ее "детей" и найти оффсет между концом выполнения дочерней вершины и началом выполнения родительской вершины:

    results = []
    for node in G.nodes:
        for child in G.neighbors(node):
            for temp in sorted_nodes:
                if temp[1] == node:
                    result1 = temp
                if temp[1] == child:
                    result2 = temp
            if result1[2] != -1 and result2[3] != -1:
                offset = result1[2] - result2[3]
            else:
                offset = -1
            results.append((f'node: {node}, Started: {result1[2]}, child: {child}, Ended: {result2[3]}',  offset))

    results = sorted(results, key=lambda x: x[1], reverse=True)

    with open('task-order-sorted-offset.txt', 'w') as file:
        file.writelines(f"{item[0]}, offset: {item[1]}\n" for item in results)

В примере выше создается файл, который содержит информацию о каждой паре вершин дочерняя-родительская и их оффсете.


## Другие способы проанализировать граф
1) Метод nx.bfs_layers позволяет составить bfs-слои, это помогает посмотреть на общий вид взаимосвязей графа

`print(dict(enumerate(nx.bfs_layers(G, ['core-image-sato.do_build']))))`

2) Метод nx.is_tree помогает проверить граф на то, является ли он деревом

`print(nx.is_tree(G))`

3) Метод nx.is_connected позволяет узнать, является ли граф связным

`print(nx.is_connected(G))`

4) Метод nx.is_directed_acyclic_graph позволяет узнать, является ли граф ацикличным

`print(nx.is_directed_acyclic_graph(G))`