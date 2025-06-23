# Creating an FTP Cache Server
### Local Preparation
1) You need to build the image  
2) Copy the `poky/build/downloads` and `poky/build/sstate-cache` folders to some external directory  

### Running the Server
A Python script has been written to run an FTP server on port 2024 (the port itself is not important, just mentioned for clarity)  
You can view the implementation code [here](./examples/setup_ftp_server.py)  
The script uses the `pyftpdlib` library, which must be installed (if not done previously) using the command `pip install pyftpdlib`  
The script is for demonstration purposes only! It needs to be modified for integration into the build system  

### Testing the Launched Server
Since the base FTP server does not have a web interface, you cannot open it in a browser.  
Therefore, you should write a program that connects to the created server.  
We will implement the following functionality: the program connects to the server, traverses the server directory tree, and outputs the encountered files and folders (this way, we demonstrate that the FTP server actually contains cache files and that we can access them):  
You can view the implementation code [here](./examples/connect_to_ftp.py)  
The script uses the `ftplib` library, which is included in the standard Python library  
The script is for demonstration purposes only! It needs to be modified for integration into the build system  

#### Screencast Demonstration of the Program:
Start of output:  
![Screenshot from 2024-04-25 21-24-13](https://github.com/moevm/os_profiling/assets/90711883/6bf49fc2-c36c-478f-9469-8f52cd5c450f)  
End of output:  
![Screenshot from 2024-04-25 21-25-33](https://github.com/moevm/os_profiling/assets/90711883/57794052-6c00-40e4-8a5f-f2358aabddf2)
