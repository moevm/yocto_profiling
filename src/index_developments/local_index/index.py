import os

def create_index(directory, output_file):
    with open(output_file, 'w') as f:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                f.write(f"{file_path}\n")

if __name__ == "__main__":
    directory_to_index = "./sstate-cache/"
    output_index_file = "index.txt"
    create_index(directory_to_index, output_index_file)
    print(f"Index file created at {output_index_file}")
