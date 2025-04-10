## build_index and timestamp

Statistics for all builds are located in `poky/build/tmp/buildstats`.  
`build_index` is the build index (counted from the end), meaning if it's set to 0, the latest build is analyzed; if 1, the second to last one, and so on.  
Alternatively, instead of specifying `build_index`, you can directly specify `timestamp` — this is the name of the folder that contains the statistics of interest.

## Launch

There are 3 target tasks:
1) Launching ranking
2) Launching dependency graph construction and its analysis
3) Launching tests

The task is set using the `-g` (`--goal`) flag and has 3 corresponding options: `-g ranking`, `-g graph`, `-g tests`.  
Let’s go through the launch of each subtask and the additional flags needed to run them.

## Ranking

To launch the ranking, the following flags are **mandatory**:
1) `-p` (`--poky_path`): path to the `poky` folder
2) `-b` (`--build_index`) OR `-t` (`--timestamp`): specify which statistics to rank — provide either `build_index` or `timestamp`

Additionally, the following flags can be provided:
1) `--border`: a float argument within the range (0, 1], indicating what percentage of ranked data to output to a file (e.g., 0.1 means 10%).  
   With this flag, you can specify, for example, that you want to output the top 10% of most loaded tasks.  
   The default value of `border` is 1, meaning all data is ranked.
2) `--metric`: a string argument specifying which metric to rank by.  
   By default, the metric is `'Elapsed time'`.  
   The specified metric must exist in the statistics.
3) `--reverse`: an integer argument; 0 means `reverse=False`, any other value means `reverse=True`.  
   If `reverse == True`, ranking is in descending order, otherwise in ascending.

Examples of launching ranking:  
`python3 main.py -g ranking -p ../../poky -b 2`  
`python3 main.py -g ranking -p ../../poky -t 20240212085739 --metric Started --reverse 0`  
`python3 main.py -g ranking -p ../../poky -b 2 --border 0.1`

## Dependency Graph

To launch construction and analysis of the dependency graph, the following flags are **mandatory**:
1) `-p` (`--poky_path`): path to the `poky` folder  
2) `-d` (`--dot_file`): path to the `.dot` file that contains dependency graph data  
3) `-b` (`--build_index`) OR `-t` (`--timestamp`): specify which statistics to correlate with the graph — provide either `build_index` or `timestamp`

*To generate a `.dot` file containing dependency graph data, you can use BitBake’s built-in functionality:  
`bitbake -g <image_name>`. Example: `bitbake -g core-image-sato`

Examples of launching graph construction and analysis:  
`python3 main.py -g graph -p ../../poky -t 20240212085739 -d ./task-depends.dot`  
`python3 main.py -g graph -p ../../poky -b 2 -d ./task-depends.dot`

## Tests

No additional flags are required other than `-g tests`.

Example of launching tests:  
`python3 main.py -g tests`
