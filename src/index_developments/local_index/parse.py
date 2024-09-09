import argparse

def parse_index(index_file):
    with open(index_file, 'r') as f:
        file_list = [line.strip() for line in f.readlines()]
    return file_list

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse an index file.")
    parser.add_argument("index_file", help="The index file to parse.", default="index.txt", nargs='?')

    args = parser.parse_args()

    files = parse_index(args.index_file)
    for file in files:
        print(file)
