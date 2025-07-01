## Dependency Graph Analysis
### Checking for the Presence of Independent Nodes
Using the `nx.bfs_layers` method, "layers" of the dependency graph were found, that is, sets of nodes located at the same "distance" from a node chosen as the zero layer. The node `core-image-sato.do_rootfs` was selected as the zero layer node. Thus, if any node had no connections to the main set of nodes, it should not have appeared in any layer. Then a comparison was made between the total number of nodes in all layers and the total number of nodes in the graph; both turned out to be equal to 8782, which tells us that there are no independent nodes (or sets of nodes).

### Finding the "Root"
Tasks are executed from the leaves to the "root", meaning at the start of the build, the leaf tasks run in parallel. By analyzing the `.dot` file, it was found that the last task to be executed (and the root of the graph) is the node `core-image-sato.do_build`, since no nodes depend on it.

### Checking for a Tree Structure
It was determined that the dependency graph does not have a tree structure. This was clearly visible during further visualization of the layers.

### Finding the Offset Between the End of the Child Node Execution and the Start of the Parent Node Execution
For each node, neighbor nodes were found (i.e., those nodes that are in direct dependency). Since the graph is directed, an edge from node A to node B exists if and only if node A depends on node B (in other words, node A is the parent of node B). For each such pair (parent node – child node), the time when the child node finished execution and when the parent node started execution was found (in this order, since the build goes from leaves to root). The offset (difference of the mentioned timestamps) was calculated, and a list of "parent-child" node pairs was created in order of decreasing offset. It turned out that the largest offsets belong to pairs where the parent node has many child nodes (i.e., the parent task depends on a large number of child tasks).

### Visualization of Graph Layers
Using a script, smaller `.dot` files were obtained from the single `task-depends.dot` file created by BitBake according to BFS layers and visualized using Graphia. The link to the folder with screenshots: https://drive.google.com/drive/folders/1iDxxq7sxxZWLCpOhBl2Xb6UEQneB_4qW?usp=drive_link. The number in the file name corresponds to the layer number. The screenshot shows the nodes of the corresponding layer and their direct connections (for example, for the first layer, the screenshot shows nodes of the first layer as well as nodes from the 0th and 2nd layers, since the nodes of the 1st layer are connected to them).
