import json

from openpyxl import Workbook
from openpyxl.styles import Alignment, Color, PatternFill


def get_tasks(parser, border, resource):
    tasks = []
    newline = False
    for time, info in parser.timeline.items():
        if not info[resource] is None and info[resource] < border:
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

def get_tasks_for_intervals(parser, intervals):
    for interval in intervals:
        for time in range(interval[0], interval[1]):
            for package in parser.info:
                for task in parser.info[package]:
                    if time > float(parser.info[package][task]['Started']) and time < float(parser.info[package][task]['Ended']):
                        interval[3].add(f'{package}.{task}')
    return intervals


def find_free_intervals(parser, resource, border):
    intervals = []
    is_free = False
    first_timestamp, last_timestamp = None, None
    for time, info in parser.timeline.items():
        if not info[resource] is None and info[resource] < border:
            if not is_free:
                is_free = True
                first_timestamp = time
        else:
            if info[resource] and info[resource] > border:
                if is_free:
                    is_free = False
                    intervals.append([first_timestamp, time, time - first_timestamp, set()])
    return sorted(intervals, key=lambda x: x[0])


def write_to_json(intervals, filename):
    items = {'items': []}
    for interval in intervals:
        items['items'].append({'Start': interval[0], 'End': interval[1], 'Duration': interval[2], 'tasks': list(interval[3])})

    with open(filename, 'w') as file:
        json.dump(items, file, indent=4)



def write_to_excel(parser):
    wb = Workbook()
    for sheet in wb.sheetnames:
        wb.remove(wb[sheet])
    ws = wb.create_sheet('sources')

    ws.column_dimensions['A'].width = 20
    ws.column_dimensions['B'].width = 10
    ws.column_dimensions['C'].width = 10
    ws.column_dimensions['D'].width = 10
    ws.column_dimensions['E'].width = 50
    for index, time in enumerate(dict(sorted(parser.timeline.items()))):
        ws.cell(row=index+1, column=1).value = time

        if not parser.timeline[time]['cpu'] is None:
            ws.cell(row=index+1, column=2).value = str(round(parser.timeline[time]['cpu'], 4))
            cpu_color = Color(
                rgb=f'ff{hex(int(255 * parser.timeline[time]["cpu"]))[2:].zfill(2)}{hex(int(255 * (1 - parser.timeline[time]["cpu"])))[2:].zfill(2)}{hex(0)[2:].zfill(2)}')
            ws.cell(row=index + 1, column=2).fill = PatternFill(fgColor=cpu_color, fill_type='solid')
        else:
            ws.cell(row=index+1, column=2).fill = PatternFill(fgColor=Color(rgb='ffffffff'), fill_type='solid')

        if not parser.timeline[time]['io'] is None:
            ws.cell(row=index+1, column=3).value = str(round(parser.timeline[time]['io'], 4))
            io_color = Color(
                rgb=f'ff{hex(int(255 * parser.timeline[time]["io"]))[2:].zfill(2)}{hex(int(255 * (1 - parser.timeline[time]["io"])))[2:].zfill(2)}{hex(0)[2:].zfill(2)}')
            ws.cell(row=index + 1, column=3).fill = PatternFill(fgColor=io_color, fill_type='solid')
        else:
            ws.cell(row=index + 1, column=3).fill = PatternFill(fgColor=Color(rgb='ffffffff'), fill_type='solid')

        if not parser.timeline[time]['ram'] is None:
            ws.cell(row=index+1, column=4).value = str(round(parser.timeline[time]['ram'], 4))
            ram_color = Color(
                rgb=f'ff{hex(int(255 * parser.timeline[time]["ram"]))[2:].zfill(2)}{hex(int(255 * (1 - parser.timeline[time]["ram"])))[2:].zfill(2)}{hex(0)[2:].zfill(2)}')
            ws.cell(row=index + 1, column=4).fill = PatternFill(fgColor=ram_color, fill_type='solid')
        else:
            ws.cell(row=index+1, column=4).fill = PatternFill(fgColor=Color(rgb='ffffffff'), fill_type='solid')

        ws.cell(row=index+1, column=5).value = '\n'.join(parser.timeline[time]['tasks'])

        for i in range(1, 6):
            ws.cell(row=index+1, column=i).alignment = Alignment(wrap_text=True)

    wb.save('./src/statistics_analyzer/output/sources.xlsx')