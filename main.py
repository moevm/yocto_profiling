import json
import os
import argparse
import unittest
from tests.src.ranking_tests import RankingTest
from tests.src.graph_tests import GraphTest
from src.statistics_analyzer.src.parsing import Parser
from src.statistics_analyzer.src.ranking import write_ranked_data, get_ranked_data_for_all_tasks
from src.dep_graph.src.analyze_graph import analyze_graph, graph_task_children
from src.statistics_analyzer.src.timeline_analyze import write_to_excel, get_tasks, find_free_intervals, get_tasks_for_intervals, write_to_json

def create_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--timestamp", type=str, help="time stamp for log files")
    parser.add_argument("-b", "--build_index", type=int, help="add specified build index")
    parser.add_argument("-p", "--poky_path", type=str, help="poky directory path")
    parser.add_argument("-g", "--goal", type=str, help="choose one of ranking/graph/tests/task_children",
                        choices=["ranking", "graph", "tests", "task_children"], required=True)
    parser.add_argument("-d", "--dot_file", type=str, help='path to .dot file to analyze')
    parser.add_argument("--border", type=float, help='border for ranking (0, 1], default=1')
    parser.add_argument("--metric", type=str, help='metric to ranking, default="Elapsed time"')
    parser.add_argument("--reverse", type=int, help='argument for reverse ranking (if specified 0 then ranking would be in ascending order)')
    args = parser.parse_args()
    return args

def start_parser(args):
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
    return parser

def start_ranking(args):
    if not args.poky_path:
        print('Enter -p (--poky_path')
        return -1
    parser = start_parser(args)
    if args.reverse is None:
        reverse = True
    else:
        if args.reverse == 0:
            reverse = False
        else:
            reverse = True

    if not args.border:
        border = 1
    else: 
        border = args.border

    if not args.metric:
        metric = 'Elapsed time'
    else:
        metric = args.metric


    data = get_ranked_data_for_all_tasks(parser.info, border=border, metric=metric, reverse=reverse)
    write_ranked_data(data, './src/statistics_analyzer/output/ranking_output.txt')


def start_graph_analyze(args):
    if not args.poky_path and not args.dot_file:
        print('Enter -p (--poky_path) and -d (--dot_file)')
        return -1
    if not args.poky_path:
        print('Enter -p (--poky_path')
        return -1
    if not args.dot_file:
        print('Enter -d (--dot_file)')
        return -1

    parser = start_parser(args)
    analyze_graph(args.dot_file, parser.info, True)


def start_task_children(args):
    if not args.dot_file:
        print('Enter -d (--dot_file)')
        return -1

    graph_task_children(args.dot_file)


def start_timeline_analyze(args):
    if not args.poky_path:
        print('Enter -p (--poky_path)')
        return -1
    parser = start_parser(args)
    parser.get_tasks_for_timeline()
    write_to_excel(parser)

    cpu_intervals, cpu_sum_time = find_free_intervals(parser, 'cpu', 0.9)
    get_tasks_for_intervals(parser, cpu_intervals)
    write_to_json(cpu_intervals, cpu_sum_time, './src/statistics_analyzer/output/cpu_intervals.json')

    io_intervals, io_sum_time = find_free_intervals(parser, 'io', 0.1)
    get_tasks_for_intervals(parser, io_intervals)
    write_to_json(io_intervals, io_sum_time, './src/statistics_analyzer/output/io_intervals.json')

    ram_intervals, ram_sum_time = find_free_intervals(parser, 'ram', 0.9)
    get_tasks_for_intervals(parser, ram_intervals)
    write_to_json(ram_intervals, ram_sum_time, './src/statistics_analyzer/output/ram_intervals.json')



def start_tests(args):
    test_suite = unittest.TestSuite()
    test_suite.addTest(unittest.makeSuite(RankingTest))
    test_suite.addTest(unittest.makeSuite(GraphTest))
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(test_suite)


if __name__ == '__main__':
    args = create_args()

    if args.goal == 'ranking':
        start_ranking(args)
    elif args.goal == 'graph':
        start_graph_analyze(args)
    elif args.goal == "task_children":
        start_task_children(args)
    elif args.goal == 'tests':
        start_tests(args)
    elif args.goal == 'timeline':
        start_timeline_analyze(args)
