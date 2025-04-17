import json
import os
import argparse
from bstask import BSTask
from task import SchedulableTask


def parse_dir(dirpath: str, bstasks: dict[str, list[BSTask]]):
    for root, _, files in os.walk(dirpath):
        for fname in files:
            if not fname.startswith("do_"):
                continue
            task = BSTask.from_file(os.path.join(root, fname))
            bstasks[task.name] = task


def emulate(tasks: dict[int, SchedulableTask], sched: list[int]) -> float:
    cores = 24
    q = list(sorted(enumerate(sched), key=lambda x: x[1]))
    passed = set()
    t = 0
    cnt = 0
    cur = []
    inflight = set()
    while len(passed) != len(q):
        for t_num, order in q:
            if len(cur) >= cores:
                # Current queue is full
                break
            if t_num in passed or t_num in inflight:
                # task is already done
                continue
            task = tasks[t_num]
            for pred in task.pred:
                if pred not in passed:
                    break
            else:
                # All reqs are done
                cur.append((t_num, task.duration))
                inflight.add(t_num)

        wait_time = min(cur, key=lambda x: x[1])[1]
        t += wait_time
        # print(len(cur), wait_time, t)
        to_remove_idxs = []
        # print("========")
        # print(cur)
        for i, (t_num, dur) in enumerate(cur):
            if wait_time >= dur:
                to_remove_idxs.insert(0, i)
                if t_num in passed:
                    print(f"{t_num} is already in passed")
                passed.add(t_num)
                inflight.remove(t_num)
                cnt += 1
            else:
                cur[i] = (t_num, dur - wait_time)

        # print(to_remove_idxs)

        for i in to_remove_idxs:
            cur.pop(i)

        # print(cur)

    # print(cnt)
    print("Emulated time:", t)
    return t


def compare_res(run_dir: str, sched, task_file, emu_origin: bool = False):
    bs_tasks: dict[str, list[BSTask]] = {}
    parse_dir(run_dir, bs_tasks)

    if not emu_origin:
        start_time = min((bs["start_time"] for bs in bs_tasks.values()))
        end_time = max((bs["start_time"] + bs.walltime for bs in bs_tasks.values()))

        print("Original time:", end_time - start_time, "s")

    with open(task_file, "r") as f:
        data = json.load(f)

    tasks: list[SchedulableTask] = []
    for d in data:
        task = SchedulableTask()
        task.from_dict(d)
        tasks.append(task)
    tasks: dict[int, SchedulableTask] = {t.num_id: t for t in tasks}

    if not emu_origin:
        # Update durations for tasks
        for task in tasks.values():
            if task.name in ("dummy_start", "dummy_end"):
                task.duration = 0
            else:
                task.duration = bs_tasks[task.name].walltime

    if emu_origin:
        # Origin schedule
        print("**** origin ****")
        orig_sched = [bs["start_time"] for bs in bs_tasks.values()]
        t_orig = emulate(tasks, orig_sched)
        print("**** new ****")
    else:
        t_orig = end_time - start_time
    # New schedule
    t = emulate(tasks, sched)
    print(t < t_orig, t_orig - t)
    print("==============")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs-dir", type=str, required=True, help="Path to dir with run_i directories")
    parser.add_argument("--sched", type=str, required=True, help="Path to schedule")
    parser.add_argument("-t", "--tasks", type=str, default="output.json", help="Filename with tasks")
    parser.add_argument("-n", "--run-num", type=int, default=30, help="Number of runs")
    parser.add_argument("--full-emu", action=argparse.BooleanOptionalAction, default=False, help="Emulate both schedules")
    # parser.add_argument("-n", "--run-num", type=int, default=30, help="Number of runs")
    # parser.add_argument("-g", "--graph", type=str, required=True, help="Graph from bitbake")
    # parser.add_argument("--mean-type", type=str, default="mean", choices=["mean", "max", "min"], help="Type of unifaction several runs")
    args = parser.parse_args()

    with open(args.sched, "r") as f:
        sched = json.load(f)

    for i in range(1, args.run_num + 1):
        d = os.path.join(args.runs_dir, f"run_{i}")
        print("=====", i, "=====")
        compare_res(os.path.join(d, os.listdir(d)[0]), sched, args.tasks, args.full_emu)


if __name__ == "__main__":
    main()
