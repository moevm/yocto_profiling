import os
import sys

def write_indexfile(directory, indexfile_name='index.txt'):
    output_file = os.path.join(directory, indexfile_name)
    with open(output_file, 'w') as f:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, directory)
                f.write(f"{relative_path}\n")

if __name__ == "__main__":
    write_indexfile(sys.argv[1])
