def sort_start_time(buildstats_info):
    tasks = []
    for package in buildstats_info:
        for task in buildstats_info[package]:
            tasks.append((package, task, float(buildstats_info[package][task]['Started']), float(buildstats_info[package][task]['Ended'])))
    return sorted(tasks, key=lambda x: x[2])



def match(node_name, sorted_nodes):
    pkg_name = node_name.split('.')[0]
    task_type = node_name.split('.')[1]
    variants = list(filter(lambda x: x[0].startswith(pkg_name), sorted_nodes)) #все задачи для пакета(-ов)
    task_variant = list(filter(lambda x: x[1] == task_type, variants)) #ищем из них с нужной задачей
    #print(node_name, task_variant)
    if len(task_variant) > 0:
        name = min(task_variant, key=lambda x: len(x[0]))
        return sorted_nodes.index(name), sorted_nodes[sorted_nodes.index(name)][2], sorted_nodes[sorted_nodes.index(name)][3]
    else: #не нашли, значит данная задача не была в статистике
        return -1, -1, -1
    return -1, -1, -1
    
def write(data, filename):
    with open(filename, 'w') as file:
        file.writelines(f"{item}\n" for item in data)




