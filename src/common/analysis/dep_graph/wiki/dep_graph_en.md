## Dependency Graph Construction

To build the dependency graph, the file `task-depends.dot` is required, which can be obtained using the following command: `bitbake -g core-image-sato`.

After obtaining the `task-depends.dot` file, we can build the dependency graph. The dependency graph was constructed in two ways:

1) Using Python with the `plotly.graph_objects` library, an `.html` file was created containing the visualization of the dependency graph:  
![image](https://github.com/moevm/os_profiling/assets/90854310/b7b2cced-3de4-4468-81e3-2fb6def2dc6f)

In this file, it is possible to zoom in on specific parts of the graph; for example, let’s look at the node `core-image-sato.do_rootfs`:  
![image](https://github.com/moevm/os_profiling/assets/90854310/7611a754-5283-4c77-8690-3b1cd9fe557e)

2) The same dependency graph was also built using Graphia; in this case, the visualization of the graph is three-dimensional. The appearance of the graph:  
![image](https://github.com/moevm/os_profiling/assets/90854310/8248dc71-0027-4b9b-9a1a-c95e4ef1dae7)  
![image](https://github.com/moevm/os_profiling/assets/90854310/45265149-d92e-4017-a012-c34363296736)

It is also possible to find a node by search and zoom in on a specific node.

For `core-image-sato`, the resulting graph consisted of 8782 nodes and 33883 edges.

## Questions Regarding the Dependency Graph

The main question is whether the dependency graph has a root; in that case, it would be more convenient to perform traversal.
