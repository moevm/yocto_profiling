# Experiment with server filtering patch

### Reproduction Instructions:
1. Start a hash server in any directory on your computer using the command: `bitbake-hashserv -b :8686`
2. Start a cache server on computer #2. I used a machine with IP `10.138.70.7`, user `user`, and port `9999`.
3. Now configure the experiment:  
  
    a. Configuration in `auto_compose_local_conf.py`
    ```py
    target_working_server_port = 9999  # the port on the cache server that is open and used for serving cache
    hash_ip_port = f'0.0.0.0:{8686}'  # the port used by the local hash server from step 1
    cache_ip =  '10.138.70.7'  # IP of the machine serving the cache
    cache_start_port = 8150  # start of the port range
    cache_num_port = 50  # number of ports to use (experiment will run from 2 up to this number + 1)
    ```  

    b. Configuration in `run.sh`
    ```bash
    max_servers=50  # maximum number of servers (minus one, effectively 50 + 1 will be tested)
    step=1  # iteration step
    ```
    You can also choose a specific poky version by setting a different commit hash there.

4. Run the experiment using `./run.sh`

### Workflow Logic
1. The file `auto_compose_local_conf.py` generates `local.conf` files for the experiment, placing them into the folder `./configs/<number_of_servers>/local.conf`
2. If `poky` is not present in the current folder, it is cloned and checked out to a specific commit hash (`59db27de565fb33f9e4326e76ebd6fa3935557b9`)
3. The patch is copied and applied
4. The script runs two experiments — one representing the behavior **before** the patch and one **after**. Because of that, the build restart block is executed twice (with different output file names to avoid overwriting the results). The first run uses only the timing patch, while the second includes the filtering patch.
5. The build loop block does the following: activates the environment (`source oe-init-build-env`), copies the generated config from step 1, starts the build and saves logs, then deletes the build directory.
