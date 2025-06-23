[Russian](README.md) | [English](README_en.md)

# **Instructions**
> The image will require at least 90Gb of memory. The build process will take over 2 hours (depending on allocated resources).

> `Docker` and `Docker compose v2` are required to perform the following steps!

You need to clone the repository. This can be done with the following command:
```
git clone https://github.com/moevm/os_profiling.git
```

## **Yocto**
A script `entrypoint.sh` was created for convenient interaction with the project. Let's look at its functionality.

1. Script functionality:
    ```
    ./entrypoint.sh
    ```
    After executing the command, a help message will be displayed with usage information, possible arguments, etc.
     ```text
      Usage: entrypoint [ env | build-env ]
                  --no-perf -- disables installation of the perf
                  --no-cache -- disables docker cache using
  
                *required stage build-env*
                [ sh | shell ]
                [ by | build-yocto ]
                    --only-poky -- only clones poky repo
                    --no-layers -- build yocto image without layers and dependencies
                    --tracing <tool> -- enables tracing of the build with one of the tools (perf, ftrace, strace)
                    --conf-file <path> -- config file to use (works only for --no-layers)
  
                *required cloned poky*
                [ p | patch ] <list_of_patches>
                    -r, --reverse -- disable choosen patches
                    -l, --patches-list -- print available patches
  
                *required built yocto*
                [ sy | start-yocto ]
  
                [ cd | clean-docker ]
                [ cb | clean-build ]
                    -o, --orig -- also cleans original poky dir
                [ deps | install-deps ]
                [ check ]
     ```

2. Checking for all required dependencies:
    ```shell
    ./entrypoint.sh check
    ```
    After executing the command, all necessary dependencies will be checked, each will have a status, followed by a summary. Example:
     ```text
      SUCCESS: docker is installed.
      SUCCESS: docker compose (v2.25.0) is installed.
      
      Verification completed successfully!
     ```

3. Environment image for the project:
   ```shell
    ./entrypoint.sh env
    ```
    This will start building the image using Docker.
    If needed, the `perf` utility can be disabled by adding the `--no-perf` flag:
      ```text
      [+] Building (12/12) FINISHED                                                                  docker:default
       => [yocto_project internal] load build definition from Dockerfile                                     
       => => transferring dockerfile: 2.24kB                                                                 
       => [yocto_project internal] load metadata for docker.io/library/ubuntu:20.04                          
       => [yocto_project internal] load .dockerignore                                                        
      ...
       => [yocto_project] exporting to image      
       => => exporting layers
       => => writing image sha256:...
       => => naming to docker.io/library/yocto-image          
      ```

4. Container command line:
      ```shell
    ./entrypoint.sh shell
    ```
    After execution, a container terminal will open:
      ```text
      [+] Running 1/1
       ✔ Container yocto_project  Started 
      To run a command as administrator (user "root"), use "sudo <command>".
      See "man sudo_root" for details.
      
      yocto_user@7212e2e38268:~/project$ 
      ...
      ```

5. Building Yocto image:
      ```shell
    ./entrypoint.sh by
    ```

    This will start building the `Yocto` image inside the container. When the container closes automatically (exit code 0), everything is installed.
    To only clone `poky`, add the `--only-poky` flag.
  
    Example successful build:
    ```text
      [+] Running 1/1
      Attaching to yocto-container
      ...
      yocto-container  | You can also run generated qemu images with a command like 'runqemu qemux86-64'.
      yocto-container  | 
      yocto-container  | Other commonly useful commands are:
      yocto-container  |  - 'devtool' and 'recipetool' handle common recipe tasks
      yocto-container  |  - 'bitbake-layers' handles common layer tasks
      yocto-container  |  - 'oe-pkgdata-util' handles common target package tasks
      yocto-container  | 
      yocto-container  | Build Configuration:
      yocto-container  | BB_VERSION           = "2.7.3"
      yocto-container  | BUILD_SYS            = "x86_64-linux"
      yocto-container  | NATIVELSBSTRING      = "universal"
      yocto-container  | TARGET_SYS           = "x86_64-poky-linux"
      yocto-container  | MACHINE              = "qemux86-64"
      yocto-container  | DISTRO               = "poky"
      yocto-container  | DISTRO_VERSION       = "4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
      yocto-container  | TUNE_FEATURES        = "m64 core2"
      yocto-container  | TARGET_FPU           = ""
      yocto-container  | meta                 
      yocto-container  | meta-poky            
      yocto-container  | meta-yocto-bsp       = "my-upstream:1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a"
      yocto-container  | 
      yocto-container  | Initialising tasks...
      yocto-container  | done.
      yocto-container  | NOTE: Executing Tasks
      ...
      yocto-container  | NOTE: Tasks Summary: Attempted 4099 tasks of which 4099 didn't need to be rerun and all succeeded.
      yocto-container exited with code 0
    ```
  
    To enable tracing during the build, use the `--tracing <tool>` option.
    Set tracing options via the `TRACING_OPTIONS` environment variable:
     ```shell
     export TRACING_OPTIONS="your_options"
     ```
  
    If using `ftrace`, since it works with kernel trace files, uncomment the following lines in this file if access issues arise:
      ```shell
      sudo mount -t debugfs none /sys/kernel/debug
      sudo chmod -R 777 /sys/kernel/debug/tracing
      ```
    **_Important: changing access rights to these files inside the Docker container will also affect the host!_**

6. Starting the Yocto image:
    ```shell
    ./entrypoint.sh sy
    ```
    This will open the `Yocto` system login screen:
     ```text
      ...
      Poky (Yocto Project Reference Distro) 4.3+snapshot-1fb353995c7fbfaa9f1614ed52a4a6aa04ccae5a qemux86-64 /dev/ttyS0
  
      qemux86-64 login: 
     ```
    All further steps are described in the ["Working with Yocto"](#Working with Yocto) section.

7. Patch management examples:
    Apply patch buildstats_netstats.patch:
     ```shell
      ./entrypoint.sh patch buildstats_netstats.patch
      ```
  
    Apply multiple patches:
     ```shell
      ./entrypoint.sh patch buildstats_netstats.patch poky_dir.patch
     ```
  
    Revert a patch:
      ```shell
      ./entrypoint.sh patch buildstats_netstats.patch -r
      ```
    Revert multiple patches similarly.
  
    List available patches:
     ```shell
      ./entrypoint.sh patch -l
     ```

### **Working with Yocto**
For system login, use login as `root`.
Congratulations, you now have access.
To exit the system:
- `Ctrl + A`, + `X`
- `Ctrl + A`, + `C`, + type `quit`

### **Build Analysis**
A [set of scripts](src/common/analysis) was developed for analysis.

To run them properly:
- Preinstalled `python3-venv`:
  ```shell
  sudo apt install python3-venv
  ```
- Install dependencies (fully automated for Linux systems):
  ```shell
  ./entrypoint.sh deps
  ```
This will create a `venv` in the (`os_profiling`) directory, activate it, and install all required dependencies.

If you already have a virtual environment, activate and install dependencies manually:
```shell
source <path-to-venv>/bin/activate
pip3 install -r <project-path>/requirements.txt
```

To deactivate:
```shell
deactivate
```


# **Experiments**
- [Experiment with cache servers](wiki/experiments/experiment_results/README_en.md)
- [Experiment with checking mirrors patch](wiki/experiments/checking_mirrors_cache_experiment/README_en.md)

## Checking mirrors patch usage (fast instruction)

### Index file for sstate-cache
* Main patch `cachefiles.patch`: adds index file check on the server. If present, uses it for optimized search on remote cache servers.
  * If not present, falls back to previous scheme.
* The index file must be located on the cache server: `$path_to_sstate_cache_dir/index.txt`
* It can be created in two ways:
  * Using `compose_indexfile.patch`, which creates it post-build in the `sstate-cache` folder.
  * Using a standalone Python script:
      ```python
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
      ```


### Mirrors availability
* Patch `async_filter_with_time.patch`: adds TCP availability check of cache mirrors.
  * Should work out of the box.
 
### Net limitation
* Patches:
  * `add_net_buildstats.patch` — collects network usage stats. Saves to `reduced_proc_net.log`, `net_pressure.log`, and `current_max_pressure.log`
  * `add_net_limit.patch` — enforces network limit. If exceeded, build task is chosen instead of fetch.
  * Should work out of the box.
 
### Task reweighing
* Main patch `add_task_children_to_weight.patch`: increases priority of tasks with more children in the dependency graph.
  * ***Requires `task-children.txt` file!***
* How to get it:
  * Export Yocto dependency graph: `bitbake -g $your_image_recipe`
  * Run [analysis tool](./src/common/analysis/): `python3 main.py -g task_children -d $path_to_generated_task_depends.dot`
  * File will be at [`dep_graph/text-files/task-children.txt`](./src/common/analysis/dep_graph/text-files/)
  * Copy it to `poky/build`
  * Patch will then activate during build.

## Patch for checking SSTATE_MIRRORS servers availability
### Problem
If broken servers are listed in `SSTATE_MIRRORS`, they are still queried for cache, slowing down `Checking sstate mirror object availability`.

### Solution
During `local.conf` parsing, asynchronous polling of `SSTATE_MIRRORS` addresses is done. Accessible ones are rewritten into the variable and a `Warning` is shown. Patch: [async_with_time_and_domains.patch](./src/yocto-patches/async_filter_with_time.patch)

### Apply patch
Move it to the poky root and run: `git apply async_filter_with_time.patch`

### Validation
1. Apply the patch.
2. Set up hash server in `local.conf`.
3. Set both working and non-working servers in `SSTATE_MIRRORS`.
4. Run build: `bitbake <target>`
5. During build, logs should show: "Time from the start to end of checking sstate availability =="
