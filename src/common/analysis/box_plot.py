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

def plot_custom_boxplot(data_list, labels, plot_name, save, show, standard_boxplot):
    fig, ax = plt.subplots()

    positions = list(range(1, len(data_list) + 1))  
    for i, data in enumerate(data_list):
        values = [item[1] / 60 for item in data]

        if standard_boxplot:
            bp = ax.boxplot(values, positions=[positions[i]], widths=0.6, patch_artist=True,
                            showmeans=False, showfliers=False,
                            medianprops={"color": "white", "linewidth": 0.5},
                            boxprops={"facecolor": "C0", "edgecolor": "white",
                                      "linewidth": 0.5},
                            whiskerprops={"color": "C0", "linewidth": 1.5},
                            capprops={"color": "C0", "linewidth": 1.5})

            ax.scatter([positions[i]] * len(values), values, color='red', alpha=0.5)
        else:
            p1, p25, p50, p75, p99 = calculate_percentiles(data)
            p1, p25, p50, p75, p99 = p1 / 60, p25 / 60, p50 / 60, p75 / 60, p99 / 60

            bp = ax.boxplot(values, positions=[positions[i]], widths=0.6, patch_artist=True,
                            showmeans=False, showfliers=False,
                            medianprops={"color": "white", "linewidth": 0.5},
                            boxprops={"facecolor": "C0", "edgecolor": "white",
                                      "linewidth": 0.5},
                            whiskerprops={"color": "C0", "linewidth": 1.5},
                            capprops={"color": "C0", "linewidth": 1.5})

            ax.plot([positions[i], positions[i]], [p1, p25], color='black', linestyle='--')
            ax.plot([positions[i], positions[i]], [p75, p99], color='black', linestyle='--')

            ax.scatter([positions[i]] * len(values), values, color='red', alpha=0.5)

            ax.text(positions[i], p1, f'1st percentile: {p1:.2f} min', verticalalignment='top', horizontalalignment='center', color='green')
            ax.text(positions[i], p99, f'99th percentile: {p99:.2f} min', verticalalignment='bottom', horizontalalignment='center', color='blue')
            ax.text(positions[i], p50, f'Median: {p50:.2f} min', verticalalignment='center', horizontalalignment='center', color='black')

    title_text = f"{plot_name}. Numbers of runs: {', '.join(map(str, [len(sublist) for sublist in data_list]))}"
    plt.title(title_text)
    plt.ylabel('Values (minutes)')
    plt.xticks(positions, labels)
    if save:
        path = './speeding_up_results/' + plot_name
        plt.savefig(path)

    if show:
        plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Specify the paths to the time.txt files.')
    parser.add_argument('--file_path_no_pathes', type=str, default='./speeding_up_results/time1.txt', help='Enter the path to the file')
    parser.add_argument('--file_path_net_patch', type=str, default='./speeding_up_results/time2.txt', help='Enter the path to the file')
    parser.add_argument('--file_path_childrens_patch', type=str, default='./speeding_up_results/time3.txt', help='Enter the path to the file')
    parser.add_argument('--file_path_all_patches', type=str, default='./speeding_up_results/time4.txt', help='Enter the path to the file')
    parser.add_argument('--plot_name', type=str, default='Patch_analysis', help='Enter title of plot')
    parser.add_argument('--save', action=argparse.BooleanOptionalAction, default=True, help='Save the plot')
    parser.add_argument('--show', action=argparse.BooleanOptionalAction, default=True, help='Show the plot')
    parser.add_argument('--standard_boxplot', action=argparse.BooleanOptionalAction, default=False, help='Use standard box plot')

    args = parser.parse_args()

    args.file_path_no_pathes = None if args.file_path_no_pathes == 'None' else args.file_path_no_pathes
    args.file_path_net_patch = None if args.file_path_net_patch == 'None' else args.file_path_net_patch
    args.file_path_childrens_patch = None if args.file_path_childrens_patch == 'None' else args.file_path_childrens_patch
    args.file_path_all_patches = None if args.file_path_all_patches == 'None' else args.file_path_all_patches
    file_paths = []
    labels = []
    if args.file_path_no_pathes is not None:
        file_paths.append(args.file_path_no_pathes)
        labels.append('No patches')
    if args.file_path_net_patch is not None:
        file_paths.append(args.file_path_net_patch)
        labels.append('Net patch')
    if args.file_path_childrens_patch is not None:
        file_paths.append(args.file_path_childrens_patch)
        labels.append('Task-childrens patch')
    if args.file_path_all_patches is not None:
        file_paths.append(args.file_path_all_patches)
        labels.append('All patches')
    
    data_list = [read_data(file_path) for file_path in file_paths]
    plot_custom_boxplot(data_list, labels, args.plot_name, args.save, args.show, args.standard_boxplot)
