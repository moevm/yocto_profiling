import networkx as nx
from src.dep_graph.src.match_graph_names import sort_start_time, match


def analyze_graph(dotfilename, info, create_txt=False):
    G = nx.DiGraph(nx.nx_pydot.read_dot(dotfilename))
    sorted_tasks = sort_start_time(info)
    sorted_nodes = []
    for node in G.nodes: #для каждой вершины найти соответствующий ей индекс в sorted_tasks
        index, start, end = match(node, sorted_tasks)
        sorted_nodes.append((index, node, start, end))

    sorted_nodes = sorted(sorted_nodes, key=lambda x:x[0])

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


    if create_txt:
        with open('./src/dep_graph/text-files/task-order-sorted-offset.txt', 'w') as file:
            file.writelines(f"{item[0]}, offset: {item[1]}\n" for item in results)
    return results
