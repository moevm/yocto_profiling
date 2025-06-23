# Speeding Up the Build

## Speedup via Network Load Limiting

At the very beginning of the build, after 13 `do_fetch` tasks have run,  
a network pressure limit is set — equal to the max load observed during that initial period.

Later, if at any moment the network load exceeds the threshold,  
tasks from the `buildable` queue are selected in this order:
- Prefer `do_compile` tasks  
- If none exist, then choose the highest-priority task **excluding** `do_fetch`

This optimization, introduced by the patch `add_net_limit.patch`,  
reduced build time from `220m24.670s` to `163m11.441s`.

Patches:  
- `add_net_limit.patch`  
- `add_net_buildstats.patch`

## Speedup via Dependency Graph

Task priority was improved by considering the number of child tasks (dependents).  
The more children, the higher the priority.

Child info is taken from the file `task-children.txt`,  
which can be generated after a normal build and by running dependency analysis as described in the [instructions](/src/dep_graph/wiki/dep_graph.md).

Move `task-children.txt` to `poky/build/` before starting the next build.

Using this optimization, build time was reduced from `216m41.635s` to `161m43.487s`.

Patch: `add_task_children_to_weight.patch`
