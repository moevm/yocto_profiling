## General Use of Local Cache

### Input Data:  
There is a built base system image located at `abs_path/build`  
Build cache: `abs_path/build/sstate-cache`  
Downloaded source data (code and more): `abs_path/build/downloads`  

### Goal  
We want to build an image with modifications or simply in a different location.

### Solution  
1) Create the build folder and initial settings using `source oe-init-build-env`  
2) In the `build/conf` folder, add the following lines to the `local.conf` file:

```bash
BB_NO_NETWORK = "1"
INHERIT += "rm_work"
DL_DIR ?= "abs_path/build/downloads"
SSTATE_DIR ?= "abs_path/build/sstate-cache"
```

Let’s take a closer look at what is configured here:
+ `BB_NO_NETWORK = "1"` – tells the build system not to download anything from the network — use only local files  
+ `INHERIT += "rm_work"` – if the build is successful, the current build files will be removed (we already have a built base image, so we don’t need to store build cache for child images, but if you remove this line — everything will still work, so it’s optional)  
+ `DL_DIR ?= "abs_path/build/downloads"` – sets the path to the folder with downloaded source code  
+ `"abs_path/build/sstate-cache"` – sets the path to the folder with the cache from the previous build

### Experiment  
The steps from the **Solution** section were followed.  
When launching a new build with the specified configuration, we got the following output:

```bash
Loading cache: 100% |                                                                                                                                                                                           | ETA:  --:--:--
Loaded 0 entries from dependency cache.
Parsing recipes: 100% |##########################################################################################################################################################################################| Time: 0:00:10
Parsing of 922 .bb files complete (0 cached, 922 parsed). 1878 targets, 47 skipped, 0 masked, 0 errors.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.9.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "ubuntu-20.04"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "5.0+snapshot-a88251b3e7077d0baf3af5f4f52928dce94aa41d"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta                 
meta-poky            
meta-yocto-bsp       = "master:a88251b3e7077d0baf3af5f4f52928dce94aa41d"

Sstate summary: Wanted 2013 Local 1138 Mirrors 0 Missed 875 Current 0 (56% match, 0% complete)################################################################################################                   | ETA:  0:00:00
Initialising tasks: 100% |#######################################################################################################################################################################################| Time: 0:00:01
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 4573 tasks of which 1863 didn't need to be rerun and all succeeded.
```

From the line `Wanted 2013 Local 1138 ...`, we can see that 1138 tasks were loaded from the external local cache, which led to 60% of the build volume completing in just a few seconds.

After a successful build using the external cache, a chart was created, which shows two facts:
1) The build took 1560 seconds (26 minutes) — thanks to the fact that no materials had to be downloaded again  
2) The tasks that take the most time are: do_configure, do_compile, do_package  
![bootchart](https://github.com/moevm/os_profiling/assets/90711883/477ae24a-15cf-474b-b758-ca1d0eb633ac)

### Conclusion  
To speed up image builds, it is possible to use cache and previously downloaded source data from earlier builds.
