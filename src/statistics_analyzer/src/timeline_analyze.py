def get_tasks(parser, border, resource, metric):
    tasks = []
    newline = False
    for time, info in parser.timeline[resource].items():
        if info[metric] < border:
            newline = True
            for package in parser.info:
                for task in parser.info[package]:
                    if time > float(parser.info[package][task]['Started']) and time < float(parser.info[package][task]['Ended']):
                        tasks.append(f'{time}: {package}.{task}\n')
        else:
            if newline:
                tasks.append('\n')
                newline = False
    return tasks