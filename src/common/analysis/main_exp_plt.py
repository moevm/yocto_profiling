import pandas as pd
import matplotlib.pyplot as plt
import argparse

def plot_graph(data, x_col, y_col, title, label, color, save_path, save, show):
    plt.figure(figsize=(10, 6))
    plt.plot(data[x_col], data[y_col], label=label, color=color)
    plt.xlabel('Number of Cache Servers')
    plt.ylabel('Time (sec)')
    plt.title(title)
    plt.legend()
    plt.grid(True)
    if save:
        plt.savefig(save_path)
    if show:
        plt.show()

def plot(data, save, show):
    plot_graph(data, 'servers num', 'avg_time',
               'Average build time depending on the number of cache servers',
               'Build time', 'r', './main_exp_data/build_time.png', save, show)

    plot_graph(data, 'servers num', 'avg_sstate_checking',
               'Average signature verification time depending on the number of cache servers',
               'Signature verification', 'g', './main_exp_data/signature_verification_time.png', save, show)

    plot_graph(data, 'servers num', 'avg_without_checking',
               'Average build time depending on the number of cache servers \n(with the deduction of signature verification time)',
               'Build time excluding signature verification', 'b', './main_exp_data/build_time_excluding_verification.png', save, show)

    plt.figure(figsize=(10, 6))
    plt.plot(data['servers num'], data['avg_time'], label='Build time', color='r')
    plt.plot(data['servers num'], data['avg_sstate_checking'], label='Signature verification', color='g')
    plt.plot(data['servers num'], data['avg_without_checking'], label='Build time excluding signature verification', color='b')
    plt.xlabel('Number of Cache Servers')
    plt.ylabel('Time (sec)')
    plt.title('Experiment result')
    plt.legend()
    plt.grid(True)
    if save:
        plt.savefig('./main_exp_data/combined_time.png')
    if show:
        plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Specify the paths to the time.txt files.')
    parser.add_argument('--file_path', type=str, default='./main_exp_data/out.csv', help='Enter the path to the file')
    parser.add_argument('--save', action=argparse.BooleanOptionalAction, default=True, help='Save the plot')
    parser.add_argument('--show', action=argparse.BooleanOptionalAction, default=True, help='Show the plot')

    args = parser.parse_args()

    data = pd.read_csv(args.file_path)

    plot(data, args.save, args.show)
