from config_parser import write_to_config
import argparse


'''
Using in ../main.sh as `python3 set_num_ports.py --cache_num_port  <val>`
'''


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--cache_num_port', type=str, required=True,
                        help='Cache number port value as a string')

    args = parser.parse_args()
    cache_num_port = args.cache_num_port

    if cache_num_port is not None:
        write_to_config('experiment.conf', 'SERVERS', 'cache_num_port', cache_num_port)

