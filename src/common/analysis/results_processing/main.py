from pathlib import Path
from typing import Any
import pandas as pd
import datetime
import matplotlib.pyplot as plt


def parse_results(filepath: Path, blocksize: int, repeatsize: int, repeatbegin: int) -> dict[int, Any]:
    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()
        redacted_lines = []

        for line in lines:
            if line == "\n":
                continue
            redacted_lines.append(line.strip())

    BLOCK_BEGIN = 0
    BLOCK_END = BLOCK_BEGIN + blocksize

    results = {}
    for i in range(0, len(redacted_lines) // blocksize):
        servers = i + 2
        block = redacted_lines[BLOCK_BEGIN:BLOCK_END:]

        REPEAT_BEGIN = repeatbegin
        REPEAT_END = REPEAT_BEGIN + repeatsize
        repeats = {}
        for j in range(0, len(block) // repeatsize):
            repeat_num = j + 1
            repeat = block[REPEAT_BEGIN:REPEAT_END]

            time, recipes_time, sstate_time = repeat
            _, _, recipes_time = recipes_time.rpartition(' ')
            _, _, sstate_time = sstate_time.rpartition(' ')

            recipes_time = datetime.datetime.strptime(recipes_time, "%H:%M:%S")
            sstate_time = datetime.datetime.strptime(sstate_time, "%H:%M:%S")

            recipes_time = recipes_time.minute * 60 + recipes_time.second
            sstate_time = sstate_time.minute * 60 + sstate_time.second
            time = int(time.removeprefix(f"REPEAT {repeat_num} TIME: "))

            repeats[repeat_num] = {
                "time": time - recipes_time,
                "sstate_checking": sstate_time,
                "without_checking": time - recipes_time - sstate_time
            }

            REPEAT_BEGIN = REPEAT_END
            REPEAT_END = REPEAT_END + repeatsize

        results[servers] = repeats
        BLOCK_BEGIN = BLOCK_END
        BLOCK_END = BLOCK_BEGIN + blocksize

    return results


def avg_for_one_sample(sample: dict[int, Any]) -> dict[str, float]:
    avg_time: float = 0.0
    avg_sstate: float = 0.0
    avg_without_checking: float = 0.0
    length = len(sample)
    for _, times in sample.items():
        avg_time += times["time"]
        avg_sstate += times["sstate_checking"]
        avg_without_checking += times["without_checking"]

    avg_time = avg_time / length
    avg_sstate = avg_sstate / length
    avg_without_checking = avg_without_checking / length

    return {
        "avg_time": round(avg_time, 2),
        "avg_sstate_checking": round(avg_sstate, 2),
        "avg_without_checking": round(avg_without_checking, 2)
    }


def get_avg(results: dict[int, Any]) -> dict[int, dict[str, float]]:
    new_results = {}
    for key, value in results.items():
        new_results[key] = avg_for_one_sample(value)

    return new_results


def get_chart_data(data: dict[int, dict[str, float]], argname: str, chartname: str) \
        -> tuple[list[float], list[float], str]:
    print(data)
    data_x = []
    data_y = []
    for key, values in data.items():
        data_x.append(key)
        data_y.append(values[argname])
    return (data_x, data_y, chartname)


def plot_charts(title: str, ylabel: str, xlabel: str, logscale: bool, *args: tuple[float, float, str]) -> None:
    plt.figure(figsize=(10, 6))
    for i, (x, y, chartname) in enumerate(args):
        plt.plot(x, y, label=chartname, marker='o')

    if logscale:
        plt.yscale('symlog', linthresh=0.001)

    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)
    plt.legend()
    plt.grid(True)
    plt.show()


if __name__ == "__main__":
    filepath_after = Path("path\\to\\your\\file\\times")
    filepath_before = Path("path\\to\\your\\another\\file\\times")

    results_after = parse_results(filepath_after, 15, 3, 0)
    results_before = parse_results(filepath_before, 16, 3, 1)

    avg_results_after = get_avg(results_after)
    avg_results_before = get_avg(results_before)

    chart_data_after = get_chart_data(avg_results_after, 'avg_time', 'result after')
    chart_data_before = get_chart_data(avg_results_before, 'avg_time', 'result before')
    plot_charts('Dependency of time on the number of servers', 'Build time, s', 'servers num', True,
                chart_data_before, chart_data_after)

    # Table with results
    # df = pd.DataFrame(avg_results_after)
    # df = df.T
    # df.insert(0, 'servers num', range(2, 54))
    #
    # markdown_table = df.to_markdown(index=False)
    # print(markdown_table)
    #
    # df.to_excel("output.xlsx", index=False)
