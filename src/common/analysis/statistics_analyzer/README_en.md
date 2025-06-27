# Running the Parser

Any program that uses internal statistics collection via the parser should be launched as follows:

```
python3 ./<name>.py --poky <path to poky folder> -b <build index>
```

or

```
python3 ./<name>.py --poky <path to poky folder> -t <specific timestamp>
```

---

## Using the Parser and Running Task Ranking

First, retrieve information about available builds and get a timestamp-sorted list of builds:

```python
args = create_parser_args()
timestamp = ''
timestamp_list = []
poky_buildstats_path = os.path.join(args.poky_path, 'build/tmp/buildstats')
tree = list(os.walk(poky_buildstats_path))
for item in tree:
    if item[0] == poky_buildstats_path:
        timestamp_list = item[1]
timestamp_list.sort(reverse=True)

if args.timestamp is None and args.build_index is None:
    print('No timestamp or build index specified')
    return
elif args.timestamp is not None and args.build_index is not None:
    print("Specify only timestamp or only build index")
    return
if args.timestamp:
    if args.timestamp in timestamp_list:
        timestamp = args.timestamp
    else:
        print('No such timestamp')
        return
else:
    if len(timestamp_list) > args.build_index:
        timestamp = timestamp_list[args.build_index]
    else:
        print('No such build index')
        return
```

Next, create a `Parser` object and start collecting statistics:

```python
parser = Parser(args.poky_path)
parser.get_data_from_buildstats(os.path.join(args.poky_path, 'build/tmp/buildstats', timestamp))
```

---

After that, you can use the collected statistics for various purposes, such as:

### Writing to Files

```python
parser.write_data_about_all_packages()
for task_type in all_tasks:
    parser.write_data_about_task(task_type)
```

---

### Ranking and Writing to File

In this example, the top 10% longest-running tasks (default metric is `'Elapsed time'`) will be written to `ranking_output.txt`:

```python
data = get_ranked_data_for_all_tasks(parser.info, parser.pid_info, border=0.1)
write_ranked_data(data, 'ranking_output.txt')
```

In this example, all tasks will be ranked by the `'Started'` metric and saved in ascending order:

```python
data = get_ranked_data_for_all_tasks(parser.info, parser.pid_info, metric='Started', border=1, reverse=False)
write_ranked_data(data, 'ranking_output.txt')
```
