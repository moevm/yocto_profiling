# Creating an HTTP Cache Server
### Local Preparation
1) You need to build the image  
2) Copy the `poky/build/downloads` and `poky/build/sstate-cache` folders to some external directory  

### Running the Server
1) In the new directory with the copied files, run the command `python3 -m http.server 8000` — the number = port (if it is busy locally — change to another one, it doesn't matter)  
![Screenshot from 2024-04-25 17-55-32](https://github.com/moevm/os_profiling/assets/90711883/ef1cfd20-acf7-4cfc-b9af-8926f4343546)

2) To check that the server is working — in the browser go to `http://localhost:8000/` — the number = port (if it is busy locally — change to another one, it doesn't matter)  
![Screenshot from 2024-04-25 17-56-55](https://github.com/moevm/os_profiling/assets/90711883/976a1b69-15ca-4d47-bf92-09edbdb339c9)
