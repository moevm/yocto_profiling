import networkx as nx
from match_graph_names import *
from parsing import *
from ranking import *
import os


def main():
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

    parser = Parser(args.poky_path)
    parser.get_data_from_buildstats(os.path.join(args.poky_path, 'build/tmp/buildstats', timestamp))
    
    G = nx.Graph(nx.nx_pydot.read_dot('./task-depends.dot'))
    sorted_tasks = sort_start_time(parser.info)
    sorted_nodes = []
    for node in G.nodes: #для каждой вершины найти соответствующий ей индекс в sorted_tasks
        index = match(node, sorted_tasks)
        sorted_nodes.append((index, node))

    sorted_nodes = sorted(sorted_nodes, key=lambda x:x[0])
    write(sorted_nodes, 'tasks-order.txt')

if __name__ == '__main__':
    main()
