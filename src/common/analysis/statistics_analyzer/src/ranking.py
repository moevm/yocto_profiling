import math
from .parsing import all_tasks


"""
While reverse=True, the "beginning" will be packets with higher resource consumption.
We can rank by any metric; by default, ranking is done by task execution time.
border is the portion of data we are interested in, i.e., if border=1, that means all available data.
For example, if reverse=True and border=0.1, we will find the top 10% most resource-consuming packets for this task.
"""
def ranking_task_info(info, task, metric='Elapsed time', border=1, reverse=True):
    task_info = []
    for package in info:
        if package in info.keys():
            for task_type in info[package]:
                if task_type == task:
                    if metric in info[package][task_type]:
                        task_info.append((package, info[package][task_type].get("PID"), info[package][task_type][metric]))
    task_info = sorted(task_info, key=lambda x: float(x[2]), reverse=reverse)[:math.floor(len(task_info) * border)]
    return task_info


def get_ranked_data_for_all_tasks(info, metric='Elapsed time', border=1, reverse=True):
    ranked_data = {task_type : ranking_task_info(info, task_type, metric=metric, border=border, reverse=reverse) for task_type in all_tasks}
    return ranked_data


def write_ranked_data(data, filename):
    with open(filename, 'w') as file:
        for task_type in data:
            file.write(task_type+'\n')
            for item in data[task_type]:
                line = ' '.join([str(x) for x in item])
                file.write(line + '\n')
            file.write('\n')
