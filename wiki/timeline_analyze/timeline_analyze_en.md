## Experiment Conditions

The experiment was conducted on the following Poky commit:  
`commit_hash = e18d60deb0496f7c91f2de900d6c024b45b7910a`

## Structure of the `sources` Table

The table contains the following columns:

1. Sec – number of seconds since the start of the build  
2. CPU – CPU load, %  
3. IO – I/O load, %  
4. RAM – RAM load, %  
5. Running tasks – tasks currently running  
6. Buildable tasks – tasks ready to be started  
7. Buildable tasks types – types of buildable tasks and their corresponding counts  
8. Skip start running info – information indicating why task execution was skipped

Columns 2, 3, and 4 are color-coded with a gradient from green to red depending on the load percentage (0% – green, 100% – red).

### Notes

1. Since task queue information updates when a task starts, while load information updates once per second, the following may occur:  
   in second `n`, several tasks are in the queue, but in second `n+1`, no tasks are shown.  
   This means the execution queue hasn’t changed and remains the same as in second `n`.

2. Since the task queue may update much more frequently than once per second, a timing error of 1 second in queue data is acceptable.

3. If in a given second the `Buildable tasks` and `Buildable tasks types` columns are non-empty, but the `Skip start running info` column says `"no buildable tasks"`,  
   this means that during that second:
   - the tasks shown in the `Buildable tasks` column were briefly present in the queue
   - and there was also a moment when there were no buildable tasks in the queue, so BitBake couldn’t start a task.

## Conclusions

The following results were obtained:

1) During approximately the first half of the build time, BitBake uses all available threads,  
   which prevents it from starting any more tasks.

2) As soon as threads are freed, we almost immediately encounter a situation where there are no buildable tasks in the queue.
