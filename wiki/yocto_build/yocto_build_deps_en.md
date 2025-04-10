# Yocto Build Dependencies

## General BitBake Workflow

1. **Parsing .bb files:**  
   BitBake parses and analyzes `.bb` files to determine tasks and corresponding functions to run.  
   Parsers are located in `/bitbake/lib/bb/parse/parse_py`:  
   https://github.com/yoctoproject/poky/tree/master/bitbake/lib/bb/parse/parse_py

2. **Dependency Tree Construction:**  
   Based on `.bb` file data, BitBake builds a dependency tree that maps relationships between tasks and recipes.  
   Function: `buildDependTree()` in `bitbake/lib/bb/cooker.py`:  
   https://github.com/yoctoproject/poky/blob/master/bitbake/lib/bb/cooker.py

3. **Run Queue Creation:**  
   BitBake creates a run queue using the `prepare()` function from `bitbake/lib/bb/runqueue.py`:  
   https://github.com/yoctoproject/poky/blob/master/bitbake/lib/bb/runqueue.py

   Each task is stored in a `RunTaskEntry` object containing:
   - `depends`: set of dependent task IDs
   - `revdeps`: set of tasks that depend on this one
   - `hash`: hash of the task
   - `unihash`: unique hash used for identification
   - `task`: task name
   - `weight`: task weight

4. **Task Execution:**  
   BitBake executes tasks in run queue order, obeying the dependency tree.  
   Function: `execute_runqueue()` in `bitbake/lib/bb/runqueue.py`.

---

## Recipe Parsing

### File Traversal Order

Recipes are selected from the `BBFILES` variable, which may include glob patterns.  
If `BBFILES` is unset, current directory recipes are used.

Patterns are prioritized via `BBFILE_PATTERN` and `BBFILE_PRIORITY` defined in the layer’s config.  
Directories are recursively scanned, globbing is used for file names, and unwanted matches are filtered out via `BBMASK`.

### Parsing Time

On commit `62e64c4cd436a0c0b8fb579fc3f664b03f49cdc9`, parsing recipes from `build/conf` took ~43 seconds.

---

### Parse Process Statistics

Use `-P` flag to collect parsing stats:
```shell
bitbake -P core-image-minimal
```

Find stats in `build/profile-parse.log.processed`. Example:
```text
Tue May 28 11:30:26 2024    profile-parse-Parser-2.log
...
         172878550 function calls (163233372 primitive calls) in 256.298 seconds

   Ordered by: internal time

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
7489144/4036531   27.886    0.000  129.390    0.000 /bb/data_smart.py:775(getVarFlag)
...
```

Field descriptions:
- **`profile-parse-Parser-X.log`** — parsing thread logs
- **function calls / time** — total + primitive calls in seconds
- **`ncalls`** — number of calls (and subcalls)
- **`tottime`** — total time (excluding subcalls)
- **`cumtime`** — cumulative time including subcalls
- **`percall`** — average time per call
- **`filename:lineno(function)`** — location of the call
