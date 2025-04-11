# Copied from https://github.com/yoctoproject/poky/blob/master/scripts/lib/buildstats.py
import json
import os
import argparse
from typing import Iterable

import numpy as np
import networkx as nx

from bstask import BSTask
from task import SchedulableTask



PARSE_ALL = False


def make_mapping(g: nx.DiGraph, task_names: Iterable[str]) -> tuple[dict[str, str], dict[str, str]]:
    mapping_from = {}
    mapping_to = {}

    node_names = set()
    for node in g.nodes:
        node_names.add(node)

    for fullname in task_names:
        reciept, subtask = fullname.rsplit(".", 1)
        # subtask = fname
        # fullname = reciept + "." + subtask
        if fullname in mapping_to:
            continue
        for i in range(1, len(reciept)):
            pname = reciept[:-i] + "." + subtask
            if pname in node_names:
                if pname in mapping_from:
                    print(f"Found duplicate: r={reciept} pname={pname} origin={mapping_from.get(pname)}")
                else:
                    # print(f"New {fullname} -> {pname}")
                    mapping_to[fullname] = pname
                    mapping_from[pname] = fullname
                break
        else:
            print(f"No mapping for {reciept}!")

    return mapping_to, mapping_from


def parse_dir(dirpath: str, bstasks: dict[str, list[BSTask]]):
    for root, _, files in os.walk(dirpath):
        for fname in files:
            if not fname.startswith("do_"):
                continue
            task = BSTask.from_file(os.path.join(root, fname))
            if bstasks.get(task.name) is None:
                bstasks[task.name] = [task]
            else:
                bstasks[task.name].append(task)


def to_sec(t: float) -> int:
    t = int(t)
    return t if t > 0 else 1


def to_msec(t: float) -> int:
    return int(t * 1000)


def export_to_json(tasks: dict[str, SchedulableTask], output_name: str):
    with open(output_name, "w") as f:
        json.dump([t.to_dict() for t in tasks.values()], f)


def export_to_dot(tasks: dict[str, SchedulableTask], output_name: str):
    g = nx.DiGraph()

    # num_to_name = {}

    for task in tasks.values():
        g.add_node(str(task.num_id + 1), size=f'"{task.duration}"', alpha='"0"')
        # num_to_name[task.num_id] = task.name

    for task in tasks.values():
        for p in task.pred:
            g.add_edge(str(p + 1), str(task.num_id + 1))

    nx.drawing.nx_pydot.write_dot(g, output_name)


def main2():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs-dir", type=str, required=True, help="Path to dir with run_i directories")
    parser.add_argument("-o", "--output", type=str, default="output.json", help="Output filename")
    parser.add_argument("-n", "--run-num", type=int, default=30, help="Number of runs")
    parser.add_argument("-g", "--graph", type=str, required=True, help="Graph from bitbake")
    parser.add_argument("--mean-type", type=str, default="mean", choices=["mean", "max", "min"], help="Type of unifaction several runs")
    parser.add_argument("--export", type=str, default="json", choices=["json", "dot"], help="Output file type")
    args = parser.parse_args()
    bs_tasks: dict[str, list[BSTask]] = {}
    for i in range(1, args.run_num + 1):
        d = os.path.join(args.runs_dir, f"run_{i}")
        parse_dir(os.path.join(d, os.listdir(d)[0]), bs_tasks)

    g = nx.DiGraph(nx.nx_pydot.read_dot(args.graph))
    task_to_node, node_to_task = make_mapping(g, bs_tasks.keys())

    if args.mean_type == "mean":
        ufunc = np.mean
    elif args.mean_type == "max":
        ufunc = np.max
    elif args.mean_type == "min":
        ufunc = np.min

    tasks: dict[str, SchedulableTask] = {}
    tasks["dummy_start"] = SchedulableTask(
        num_id=0,
        pred=[],
        duration=0,
        name="dummy_start",
        res_cpu=0,
        res_io=0,
        res_net=0,
    )
    index_offset = 0
    for index, node_name in enumerate(nx.topological_sort(g)):
        task_name = node_to_task.get(node_name)
        if task_name is None:
            index_offset += 1
            continue
        bss = bs_tasks[task_name]
        assert len(bss) == args.run_num, f"Found only {len(bss)} BSTask for {task_name}"
        t = SchedulableTask(
            num_id=index - index_offset + 1,
            pred=[],
            duration=to_sec(np.mean([b["elapsed_time"] for b in bss])),
            name=bss[0].name,
            res_cpu=to_msec(ufunc([b.proc_time for b in bss])),
            res_io=int(ufunc([b.io_bytes for b in bss])),
            res_net=int(ufunc([b.net_bytes for b in bss])),
        )
        tasks[t.name] = t

    last_index = index - index_offset + 2
    tasks["dummy_end"] = SchedulableTask(
        num_id=last_index,
        pred=[],
        duration=0,
        name="dummy_end",
        res_cpu=0,
        res_io=0,
        res_net=0,
    )

    # for n in successors(x): there are edges from x->n
    for task in tasks.values():
        if task.name in {"dummy_start", "dummy_end"}:
            continue
        task.pred = [
            tasks[node_to_task[predcessor]].num_id
            for predcessor in g.predecessors(task_to_node[task.name])
            if predcessor in node_to_task
        ]

    for node in g.nodes:
        if node not in node_to_task:
            continue
        if len(list(g.successors(node))) == 0:
            # No output edges, add edge to the dummy_end
            tasks["dummy_end"].pred.append(tasks[node_to_task[node]].num_id)
        if len(list(g.predecessors(node))) == 0:
            # No input edge, add edge from dummy_start to node
            tasks[node_to_task[node]].pred.append(tasks["dummy_start"].num_id)

    # print(tasks["dummy_end"])
    for task in tasks.values():
        task.pred = sorted(task.pred)

    print("Parsed", len(tasks), "tasks from", len(g.nodes), "in graph")

    if args.export == "json":
        export_to_json(tasks, args.output)
    elif args.export == "dot":
        export_to_dot(tasks, args.output)


def main(dirpath: str):
    tasks: list[BSTask] = []
    for root, _, files in os.walk(dirpath):
        for fname in files:
            if not fname.startswith("do_"):
                continue
            task = BSTask.from_file(os.path.join(root, fname))
            tasks.append(task)

    print("Task count:", len(tasks))
    print("Max proc:", max((t.proc_time for t in tasks)), "s")
    print("Min proc:", min((t.proc_time for t in tasks)), "s")
    print("Max io:", max((t.io_bytes for t in tasks)) / 2 ** 20, "MB")
    print("Min io:", min((t.io_bytes for t in tasks)) / 2 ** 20, "MB")
    print("Max net:", max((t.net_bytes for t in tasks)) / 2 ** 20, "MB")
    print("Min net:", min((t.net_bytes for t in tasks)) / 2 ** 20, "MB")
    print("Max iops:", max((t.iops for t in tasks)))
    print("Min iops:", min((t.iops for t in tasks)))
    print("=======")
    if not PARSE_ALL:
        print("Max proc:", max(tasks, key=lambda t: t.proc_time), "s")
        print("Min proc:", min(tasks, key=lambda t: t.proc_time), "s")
        print("Max io:", max(tasks, key=lambda t: t.io_bytes))
        print("Min io:", min(tasks, key=lambda t: t.io_bytes))
        print("Max net:", max(tasks, key=lambda t: t.net_bytes))
        print("Min net:", min(tasks, key=lambda t: t.net_bytes))
        print("Max iops:", max(tasks, key=lambda t: t.iops))
        print("Min iops:", min(tasks, key=lambda t: t.iops))
        for t in sorted(tasks, key=lambda t: t.io_bytes, reverse=True)[:20]:
            print(f"Task {t.name} duration={t['elapsed_time']} io_bytes={t.io_bytes / 2 ** 20} MB iops={t.iops} MB/s")


if __name__ == "__main__":
    main2()
    # if PARSE_ALL:
    #     for i in range(1, 31):
    #         d = f"buildstats_saves_no_patches/run_{i}"
    #         n = os.listdir(d)[0]
    #         print(os.path.join(d, n))
    #         main(os.path.join(d, n))
    # else:
    #     main("buildstats_saves_no_patches/run_1/20241029183623/")
