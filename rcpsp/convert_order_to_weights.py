import json
import sys

from task import SchedulableTask


def get_order(num):
    ret = 10
    while num > 0:
        ret *= 10
        num //= 10
    return ret


def main():
    with open(sys.argv[1], "r") as f:
        sched_origin = json.load(f)

    with open(sys.argv[2], "r") as f:
        data = json.load(f)

    tasks: list[SchedulableTask] = []
    for d in data:
        task = SchedulableTask()
        task.from_dict(d)
        tasks.append(task)

    tasks = sorted(tasks, key=lambda t: t.num_id)
    max_t = max(sched_origin)
    order = get_order(max_t)
    weights = [order / (s + 1) for s in sched_origin]

    with open(sys.argv[3], "w") as f:
        for t, w in zip(tasks, weights):
            name = t.receipt.replace('.bb"', "") + "." + t.name.rsplit(".")[-1]
            f.write(f"{name} {int(w)}\n")


if __name__ == "__main__":
    main()
