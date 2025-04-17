import json
import sys
import random

from task import SchedulableTask


def get_order(num):
    ret = 1
    while num > 0:
        ret *= 10
        num //= 10
    return ret


def main(path: str):
    with open(path, "r") as f:
        data = json.load(f)
    tasks: list[SchedulableTask] = []
    for d in data:
        task = SchedulableTask()
        task.from_dict(d)
        tasks.append(task)

    tasks = sorted(tasks, key=lambda t: t.num_id)
    successors = [task.pred.copy() for task in tasks]
    predecessors = [[] for _ in range(len(successors))]

    for job in range(len(successors)):
        for succ in successors[job]:
            if succ >= len(predecessors):
                print(f"Succ {succ} > pred {len(predecessors)}")
            predecessors[succ].append(job)

    predecessors, successors = successors, predecessors

    # ============

    weights = [10 for _ in tasks]
    next_tasks = [i for i in range(len(tasks)) if len(successors[i]) == 0]

    while len(next_tasks) > 0:
        cur_task = next_tasks.pop()
        for pred in predecessors[cur_task]:
            weights[pred] += weights[cur_task]
            successors[pred].remove(cur_task)
            if len(successors[pred]) == 0:
                next_tasks.insert(0, pred)

    build_coeff = max(weights) / 10 * 1.5
    time_coeff = build_coeff * 2

    for i, t in enumerate(tasks):
        if t.name.endswith(".do_compile"):
            weights[i] += build_coeff
        if t.duration >= 7 * 60:
            weights[i] += time_coeff

    max_w = max(weights)
    order = get_order(max_w)

    print("order is", order)

    weights = [order / w for w in weights]
    # weights = [random.random() * 1000000 for w in weights]
    # weights = [i for i in range(len(weights))]

    with open("sched_custom.json", "w") as f:
        json.dump(weights, f)


if __name__ == "__main__":
    main(sys.argv[1])

