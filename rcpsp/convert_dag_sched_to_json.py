import json
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, required=True, help="Input file from DAG_Scheduling")
    parser.add_argument("-o", "--output", type=str, required=True, help="Output file in json format")
    args = parser.parse_args()

    node_to_time = {}
    with open(args.input, "r") as f:
        for line in f:
            line = line.strip()
            idx1 = line.find("start = ")
            idx2 = line.find(", end = ")
            if idx1 == -1 or idx2 == -1:
                continue
            stime = float(line[idx1 + len("start = "):idx2])
            idx1 = line.find(" ")
            idx2 = line.find(":")
            num = int(line[idx1:idx2])
            node_to_time[num] = stime

    num_max = max(node_to_time.keys())
    print("Max task num:", num_max)
    offset = 1
    if 0 in node_to_time:
        del node_to_time[0]
    else:
        del node_to_time[1]
        offset = 2
    del node_to_time[num_max]

    l = [0 for _ in range(num_max - offset)]

    for num, stime in node_to_time.items():
        if num - offset >= len(l):
            print(num, "is out of range, len is", len(l))
        l[num - offset] = stime

    print("Number of tasks:", len(l))

    with open(args.output, "w") as f:
        json.dump(l, f)


if __name__ == "__main__":
    main()
