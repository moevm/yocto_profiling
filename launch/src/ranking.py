import math
from parsing import all_tasks

#Пока reverse=True, "в начале" будут пакеты с большей затратой ресурсов.
#Можем ранжировать по любой метрике, по умолчанию ранжируется по времени выполнения задачи.
#border - доля данных, которая нас интересует, т.е. если border=1, то это все имеющиеся данные,
# например, если reverse=True и border=0.1, то найдем 10% самых затратных пакетов по этой задаче
def ranking_task_info(info, pid_info, task, metric='Elapsed time', border=1, reverse=True):
    task_info = []
    for package in info:
        if package in info.keys() and package in pid_info.keys():
            for task_type in info[package]:
                if task_type == task:
                    if metric in info[package][task_type]:
                        task_info.append((package, pid_info[package][task_type].get("PID"), info[package][task_type][metric]))
    task_info = sorted(task_info, key=lambda x: float(x[2]), reverse=reverse)[:math.floor(len(task_info) * border)]
    return task_info


def get_ranked_data_for_all_tasks(info, pid_info, metric='Elapsed time', border=1, reverse=True):
    ranked_data = {task_type : ranking_task_info(info, pid_info, task_type, metric=metric, border=border, reverse=reverse) for task_type in all_tasks}
    return ranked_data


def write_ranked_data(data, filename):
    with open(filename, 'w') as file:
        for task_type in data:
            file.write(task_type+'\n')
            for item in data[task_type]:
                line = ' '.join([str(x) for x in item])
                file.write(line + '\n')
            file.write('\n')
