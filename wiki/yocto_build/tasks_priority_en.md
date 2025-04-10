# How and Where Task Priority is Set

Task weight is assigned in the `calculate_task_weights` method of the `RunQueueData` class in  
`bitbake/lib/bb/runqueue.py`.

The greater the weight, the higher the task's priority.  
Initially, each task has weight = 1.  
Final tasks (`endpoints`) have weight = 10.

Then for each endpoint, BitBake checks which other tasks depend on it,  
and increases the dependent tasks’ weights accordingly.  
So, the more tasks rely on a given task, the heavier (more important) it is.

## Experiment: Changing Weights of `do_configure` and `do_compile`

Weights of `do_configure` and `do_compile` tasks were manually set to 9:

```python
def calculate_task_weights(self, endpoints):
    ...
    for tid in self.runtaskentries:
        task_done[tid] = False
        if tid.endswith("do_compile") or tid.endswith("do_configure"):
            weight[tid] = 9
        else:
            weight[tid] = 1
        deps_left[tid] = len(self.runtaskentries[tid].revdeps)
```

Then a `core-image-minimal` build was run.

Results:
- With custom task weights: 221 minutes  
- Default build (no changes): 190 minutes
