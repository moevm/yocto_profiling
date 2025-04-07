import networkx as nx
import sys
import os
import json


g = nx.DiGraph(nx.nx_pydot.read_dot(sys.argv[1]))

node_names = set()
for node in g.nodes:
    node_names.add(node)

print(f"{len(node_names)} tasks in graph")

mapping_from = {}
mapping_to = {}

for root, dirs, files in os.walk(sys.argv[2]):
    for fname in files:
        if not fname.startswith("do_"):
            continue
        reciept = os.path.basename(root)
        subtask = fname
        fullname = reciept + "." + subtask
        if fullname in mapping_to:
            continue
        for i in range(1, len(reciept)):
            pname = reciept[:-i] + "." + subtask
            if pname in node_names:
                if pname in mapping_from:
                    print(f"Found duplicate: r={reciept} pname={pname} origin={mapping_from.get(pname)}")
                else:
                    # print(f"New {fullname} -> {pname}")
                    mapping_to[fullname] = pname
                    mapping_from[pname] = fullname
                break
        else:
            print(f"No mapping for {reciept}!")

print("Tasks found:", len(mapping_to))
print("Not found:", " ".join(n for n in g.nodes if n not in mapping_from))
