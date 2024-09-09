def parse_index(index_file):
    with open(index_file, 'r') as f:
        file_list = [line.strip() for line in f.readlines()]
    return file_list

if __name__ == "__main__":
    index_file = "index.txt"
    files = parse_index(index_file)
    for file in files:
        print(file)
