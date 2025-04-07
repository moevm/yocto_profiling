# Copied from https://github.com/yoctoproject/poky/blob/master/scripts/lib/buildstats.py
import os
import argparse
from bstask import BSTask
from task import SchedulableTask
import json
import numpy as np
import networkx as nx


PARSE_ALL = False


def make_mapping(g: nx.DiGraph, dirpath: str) -> tuple[dict[str, str], dict[str, str]]:
    mapping_from = {}
    mapping_to = {}

    node_names = set()
    for node in g.nodes:
        node_names.add(node)

    for root, dirs, files in os.walk(dirpath):
        for fname in files:
            if not fname.startswith("do_"):
                continue
            reciept = os.path.basename(root)
            subtask = fname
            fullname = reciept + "." + subtask
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
    for root, dirs, files in os.walk(dirpath):
        for fname in files:
            if not fname.startswith("do_"):
                continue
            task = BSTask.from_file(os.path.join(root, fname))
            if bstasks.get(task.name) is None:
                bstasks[task.name] = [task]
            else:
                bstasks[task.name].append(task)


def main2():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs-dir", type=str, required=True, help="Path to dir with run_i directories")
    parser.add_argument("-o", "--output", type=str, default="output.json", help="Output filename")
    parser.add_argument("-n", "--run-num", type=int, default=30, help="Number of runs")
    parser.add_argument("-g", "--graph", type=str, required=True, help="Graph from bitbake")
    args = parser.parse_args()
    bs_tasks: dict[str, list[BSTask]] = {}
    for i in range(1, args.run_num + 1):
        d = os.path.join(args.runs_dir, f"run_{i}")
        parse_dir(os.path.join(d, os.listdir(d)[0]), bs_tasks)

    tasks: dict[str, SchedulableTask] = {}
    for index, (name, bss) in enumerate(bs_tasks.items()):
        assert len(bss) == args.run_num
        t = SchedulableTask(
            index,
            [],
            np.mean([b["elapsed_time"] for b in bss]),
            bss[0].name,
            np.mean([b.proc_time for b in bss]),
            np.mean([b.io_bytes for b in bss]),
            np.mean([b.net_bytes for b in bss]),
        )
        tasks[t.name] = t

    g = nx.DiGraph(nx.nx_pydot.read_dot(args.graph))
    task_to_node, node_to_task = make_mapping(g, os.path.join(args.runs_dir, "run_1"))

    for task in tasks.values():
        task.pred = [
            tasks[node_to_task[successor]].num_id
            for successor in g.successors(task_to_node[task.name])
            if successor in node_to_task
        ]

    with open(args.output, "w") as f:
        json.dump([t.to_dict() for t in tasks.values()], f)


def main(dirpath: str):
    tasks: list[BSTask] = []
    for root, dirs, files in os.walk(dirpath):
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
