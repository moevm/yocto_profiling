# Как и где устанавливается приоритет задач

Вес задач устанавливается в методе `calculate_task_weights` класса `RunQueueData` в файле `bitbake/lib/bb/runqueue.py`.
Чем больше вес, тем больше приоритет у задачи. Изначально для каждой задачи вес равен 1, для конечных задач 
(`endpoints`) вес равен 10. Затем для каждой конечной задачи проверяется, зависят ли от нее другие задачи, и если
зависят, то вес зависимой задачи увеличивается на вес задачи, от которой она зависит. Таким образом, задача тяжелее, 
чем больше других задач зависит от нее.

## Эксперимент: изменение приоритета do_configure и do_compile задач

Был проведен эксперимент: для задач `do_configure` и `do_compile` были установлены веса 9 следующим образом:

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

Затем была запущена сборка образа `core-image-minimal`. В результате сборка с изменением приоритетов задач заняла 221
минуту, в то время как сборка без изменения приоритетов заняла 190 минут.