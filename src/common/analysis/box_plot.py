import argparse
import matplotlib.pyplot as plt
import numpy as np

def read_data(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.split(':')
            if len(parts) == 2 and line.startswith('run'):
                run_number = int(parts[0].split()[1])
                value = int(parts[1].strip())
                data.append((run_number, value))
    return data

def calculate_percentiles(data):
    values = [item[1] for item in data]
    p1 = np.percentile(values, 1)
    p25 = np.percentile(values, 25)
    p50 = np.percentile(values, 50)
    p75 = np.percentile(values, 75)
    p99 = np.percentile(values, 99)
    return p1, p25, p50, p75, p99

def plot_custom_boxplot(data, plot_name, save, show):
    values = [item[1] / 60 for item in data] 
    p1, p25, p50, p75, p99 = calculate_percentiles(data)
    p1, p25, p50, p75, p99 = p1 / 60, p25 / 60, p50 / 60, p75 / 60, p99 / 60  

    fig, ax = plt.subplots()

    ax.boxplot([values], positions=[1], widths=0.6, patch_artist=True,
               showmeans=False, showfliers=False,
               medianprops={"color": "white", "linewidth": 0.5},
               boxprops={"facecolor": "C0", "edgecolor": "white",
                         "linewidth": 0.5},
               whiskerprops={"color": "C0", "linewidth": 1.5},
               capprops={"color": "C0", "linewidth": 1.5})

    ax.plot([1, 1], [p1, p25], color='black', linestyle='--')
    ax.plot([1, 1], [p75, p99], color='black', linestyle='--')

    ax.text(1, p1, f'1st percentile: {p1:.2f} min', verticalalignment='top', horizontalalignment='center', color='red')
    ax.text(1, p99, f'99th percentile: {p99:.2f} min', verticalalignment='bottom', horizontalalignment='center', color='blue')
    ax.text(1, p50, f'Median: {p50:.2f} min', verticalalignment='center', horizontalalignment='center', color='green')

    plt.title(plot_name)
    plt.ylabel('Values (minutes)')
    plt.xticks([])

    if save:
        plt.savefig(plot_name)

    if show:
        plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Specify the path to the time.txt file.')
    parser.add_argument('--file_path', type=str, default='time.txt', help='Enter the path to the file')
    parser.add_argument('--plot_name', type=str, default='No-name', help='Enter title of plot')
    parser.add_argument('--save', action=argparse.BooleanOptionalAction, default=True, help='Save the plot')
    parser.add_argument('--show', action=argparse.BooleanOptionalAction, default=True, help='Show the plot')

    args = parser.parse_args()
    file_path = args.file_path
    data = read_data(file_path)
    plot_custom_boxplot(data, args.plot_name, args.save, args.show)
