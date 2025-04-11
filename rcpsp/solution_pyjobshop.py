import json
from dataclasses import dataclass
from typing import NamedTuple

from pyjobshop import Model
from pyjobshop.plot import plot_resource_usage, plot_task_gantt
import matplotlib.pyplot as plt

from task import SchedulableTask


class Mode(NamedTuple):
    job: int
    duration: int
    demands: list[int]


@dataclass(frozen=True)
class Instance:
    """
    Problem instance class based on PSPLIB files.

    Code taken from:
    https://alns.readthedocs.io/en/latest/examples/resource_constrained_project_scheduling_problem.html
    """

    num_jobs: int  # jobs in RCPSP are tasks in PyJobshop
    num_resources: int
    successors: list[list[int]]
    predecessors: list[list[int]]
    modes: list[Mode]
    capacities: list[int]
    renewable: list[bool]

    @classmethod
    def read_instance(cls, path: str) -> "Instance":
        """
        Reads an instance of the RCPSP from a file.
        Assumes the data is in the PSPLIB format.
        """
        with open(path, "r") as f:
            data = json.load(f)

        cpu_cores = 24
        max_io = 260  # in MB
        max_net = 70  # in MB
        resources = [
            cpu_cores,  # Cores in the system, max parallel tasks
            cpu_cores * 1000,  # Max cpu consumption in ms
            max_io * 2 ** 20,  # IO consumption in Bytes
            max_net * 2 ** 20,  # Net consumption in Bytes
        ]
        successors = []
        needs = []
        durations = []

        tasks: list[SchedulableTask] = []
        for d in data:
            task = SchedulableTask()
            task.from_dict(d)
            tasks.append(task)

        tasks = sorted(tasks, key=lambda t: t.num_id)
        modes = []
        for task in tasks:
            successors.append(task.pred.copy())
            durations.append(task.duration)
            modes.append(Mode(task.num_id, task.duration,
                [
                    task.res_parallel,
                    task.res_cpu,
                    task.res_io,
                    task.res_net,
                ]
            ))

        predecessors = [[] for _ in range(len(successors))]

        for job in range(len(successors)):
            for succ in successors[job]:
                if succ >= len(predecessors):
                    print(f"Succ {succ} > pred {len(predecessors)}")
                predecessors[succ].append(job)

        print(tasks[2164])

        return Instance(
            len(durations),
            len(resources),
            predecessors,  # Swapped!!!
            successors,
            modes,
            resources,
            [True for _ in range(len(resources))]
        )


instance = Instance.read_instance("output_max.json")
model = Model()

# It's not necessary to define jobs, but it will add coloring to the plot.
jobs = [model.add_job() for _ in range(instance.num_jobs)]
tasks = [model.add_task(job=jobs[idx]) for idx in range(instance.num_jobs)]
resources = [model.add_renewable(capacity) for capacity in instance.capacities]
for idx, duration, demands in instance.modes:
    model.add_mode(tasks[idx], resources, duration, demands)

for idx in range(instance.num_jobs):
    task = tasks[idx]

    for pred in instance.predecessors[idx]:
        model.add_end_before_start(tasks[pred], task)

    for succ in instance.successors[idx]:
        model.add_end_before_start(task, tasks[succ])

result = model.solve(time_limit=60, display=False, num_workers=6)
print(result)
data = model.data()
fig, axes = plt.subplots(
    data.num_resources + 1,
    figsize=(12, 16),
    gridspec_kw={"height_ratios": [6] + [1] * data.num_resources},
)

plot_task_gantt(result.best, model.data(), ax=axes[0])
plot_resource_usage(result.best, model.data(), axes=axes[1:])

plt.savefig("pyjobshop.png")
