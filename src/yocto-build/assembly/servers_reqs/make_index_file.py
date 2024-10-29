import os
import sys

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"USAGE: {sys.argv[0]} </path/to/sstate_dir>")
        exit(1)
    directory = sys.argv[1]
    output_file = os.path.join(directory, 'index.txt')
    with open(output_file, 'w') as f:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, directory)
                f.write(f"{relative_path}\n")
