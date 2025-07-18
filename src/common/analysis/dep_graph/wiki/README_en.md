## Using the program for sorting graph nodes and finding offsets

First, it is necessary to run the parser and collect statistics (instructions for running the parser and collecting statistics are described here: https://github.com/moevm/os_profiling/blob/denisova_olga_parsing_ranking/statistics_analyzer/README.md)

Also, before analyzing the dependency graph, it is necessary to create the file task-depends.dot (creating this file and visualizing the graph is described here: https://github.com/moevm/os_profiling/blob/denisova_olga_dep_graph/dep_graph/wiki/dep_graph.md)

Then you can create a graph object and analyze it:

    G = nx.DiGraph(nx.nx_pydot.read_dot('./task-depends.dot'))
    sorted_tasks = sort_start_time(parser.info)
    sorted_nodes = []
    for node in G.nodes:  # for each node find the corresponding index in sorted_tasks
        index, start, end = match(node, sorted_tasks)
        sorted_nodes.append((index, node, start, end))

    sorted_nodes = sorted(sorted_nodes, key=lambda x: x[0])
    # write(sorted_nodes, 'tasks-order.txt')  # tasks can be written to a file in the order of their start time

In the example above, graph nodes are matched with objects from the statistics, and nodes are numbered in the order of their start time.

For each node, you can find its "children" and find the offset between the end of the child's execution and the start of the parent's execution:

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

In the example above, a file is created that contains information about each parent-child node pair and their offset.

## Other ways to analyze the graph

1) The method nx.bfs_layers allows composing BFS layers, which helps to look at the overall view of the graph's interconnections

    print(dict(enumerate(nx.bfs_layers(G, ['core-image-sato.do_build']))))

2) The method nx.is_tree helps check whether the graph is a tree

    print(nx.is_tree(G))

3) The method nx.is_connected allows finding out whether the graph is connected

    print(nx.is_connected(G))

4) The method nx.is_directed_acyclic_graph allows finding out whether the graph is acyclic

    print(nx.is_directed_acyclic_graph(G))
