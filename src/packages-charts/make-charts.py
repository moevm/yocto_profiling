import os
import matplotlib.pyplot as plt


def create_fs_tree(path):
    tree = os.walk(path)
    return tree


def create_chart(tree, timestamp_list):
    metrics = ['utime', 'stime', 'cutime', 'cstime', 'IO rchar', 'IO wchar', 'rusage ru_utime', 'rusage ru_stime', 'rusage ru_maxrss', 'Child rusage ru_utime', 'Child rusage ru_stime'] #можно что-то добавить
    num_metrics = len(metrics)
    
    for i in range(num_metrics):
        data = create_data(metrics[i], tree, timestamp_list)
        sorted_data = dict(sorted(data.items(), key=lambda item: item[1]))
        plt.figure(figsize=(10, 70))
        plt.barh(list(sorted_data.keys()), list(sorted_data.values()))
        plt.title(label=metrics[i], fontsize=20)
        plt.tight_layout()
        plt.xticks(rotation=90)
        plt.savefig(metrics[i]+'.png')
    

def create_data(metric, tree, timestamp_list):
    result = dict()
    for package in tree:
            data = 0
            if package[1] == []:
                for task in package[2]:
                    if task.startswith('do_'):
                        with open(package[0] + '/' + task, 'r') as file:
                            for line in file:
                                if line.startswith(metric + ': '):
                                    data += float(line[line.index(':') + 2 : ])
            if (not package[0].endswith('reduced_proc_pressure')) and (not (package[0].split('/'))[-1] in timestamp_list):
                result.update({package[0][package[0].rfind('/') + 1 :] : data})
    return result


def main():
    timestamp = ''
    tree = list(os.walk('poky/build/tmp/buildstats'))
    for item in tree:
        if item[0] == 'poky/build/tmp/buildstats':
            timestamp_list = item[1]
    timestamp_list.sort(reverse=True)

    if len(sys.argv) < 2:
        print('No timestamp or build index specified')
        return
    if sys.argv[1] == '-b': 
        if len(timestamp_list) >= int(sys.argv[2]):
            timestamp = timestamp_list[int(sys.argv[2])]
        else:
            print('No such build index')
            return
    else:
        if sys.argv[1] in timestamp_list:
            timestamp = sys.argv[1]
        else:
            print('No such timestamp')
            return

    create_chart(list(create_fs_tree('poky/build/tmp/buildstats'+timestamp)), timestamp_list)


if __name__ == '__main__':
    main()
