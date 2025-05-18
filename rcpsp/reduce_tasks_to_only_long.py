# Reduce the number of task
# All tasks that have execution time <= 1s will be removed

import json
import sys
from task import SchedulableTask

with open(sys.argv[1], "r") as f:
    data = json.load(f)
tasks: list[SchedulableTask] = []
for d in data:
    task = SchedulableTask()
    task.from_dict(d)
    tasks.append(task)

tasks = sorted(tasks, key=lambda t: t.num_id)

def remove_task(number: int):
    nodes_in = tasks[number].pred.copy()
    nodes_out = [t.num_id for t in tasks if number in t.pred]
    for node_num in nodes_out:
        task = tasks[node_num]
        task.pred.remove(number)
        for ni in nodes_in:
            if ni not in task.pred:
                task.pred.append(ni)


reduced_tasks = []

for t in tasks:
    if (t.duration <= 1 or t.name.endswith("do_fetch")) and t.name not in ("dummy_start", "dummy_end"):
        remove_task(t.num_id)
    else:
        reduced_tasks.append(t)

print("Red num:", len(reduced_tasks))

red_num_mapping = {}   # key -- old, value -- new

for i, t in enumerate(reduced_tasks):
    red_num_mapping[t.num_id] = i
    t.num_id = i

for t in reduced_tasks:
    t.pred = [red_num_mapping[ti] for ti in t.pred]

with open(sys.argv[2], "w") as f:
    json.dump([rt.to_dict() for rt in reduced_tasks], f)
