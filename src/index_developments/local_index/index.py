import os
import argparse

def create_index(directory, output_file):
    with open(output_file, 'w') as f:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                f.write(f"{file_path}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create an index file of a directory.")
    parser.add_argument("directory", help="The directory to index.", default="./sstate-cache/", nargs='?')
    parser.add_argument("output_file", help="The output index file.", default="index.txt", nargs='?')

    args = parser.parse_args()

    create_index(args.directory, args.output_file)
    print(f"Index file created at {args.output_file}")
