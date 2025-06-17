from ftplib import FTP

def list_files_in_dir(ftp, path):
    files = []
    ftp.cwd(path)
    ftp.retrlines('LIST', lambda line: files.append(line.split()[-1]))
    for file in files:
        if file.startswith('.'):  # Skip hidden files
            continue
        if '.' in file:  
            print(path + '/' + file)
        else:  # If it is a directory
            list_files_in_dir(ftp, path + '/' + file)

if __name__ == '__main__':
    ftp = FTP() # Connecting to the FTP server
    ftp.connect('localhost', 2024)  
    ftp.login()  
    files = ftp.nlst()

    list_files_in_dir(ftp, '/')

    ftp.quit()
