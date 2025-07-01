### Instruction — Step-by-Step Guide for Conducting the Experiment

1. Set up SSH as described in the [SSH setup guide](/wiki/yocto_cache/ssh_connection.md).

2. Fill in the [configuration file](src/setup_servers/auto_conf/[example]_experiment.conf) located at  
   `.../src/experiment/auto_conf/experiment.conf`:

   - a) `cache_ip`, `hash_ip` — IP addresses of your cache and hash servers (those configured in step 1).
   - b) `cache_usr`, `hash_usr` — SSH usernames for your cache and hash servers (from step 1).
   - c) `hash_port` — port to be used for the hash server.
   - d) `cache_start_port` — starting port on the cache server; used for launching multiple cache instances.
   - e) `cache_num_port` — number of ports to be used by cache servers; resulting in port usage from `{cache_start_port}` to `{cache_start_port + cache_num_port - 1}`.
   - f) `step` — step increment for the experiment’s loop.
   - g) `max_servers` — upper limit of cache server count in the test.

3. During the experiment, output files are automatically generated in the repository root in the format `test_n_m`, where:
   - `n` — number of cache servers used,
   - `m` — experiment repetition number:  
     If `m=1`, the build was done **without** a hash server cache.  
     If `m=2`, the build was done **with** the hash server cache.

---

### How the Experiment Works

#### Hash Server
Everything related to hash server setup is located in `.../src/experiment/hash_server_setuper`, which also contains a `README.md`.

#### Cache Server
To correctly conduct the experiment, clone the project repository on the machine intended to run as a cache server at this path:  
`/home/user/Desktop/test`

Then, inside the `src` directory, run:
```sh
python3 -m venv venv
source venv/bin/activate
cd ./experiment/cache_server_setuper/reqs && pip3 install -r requirements.txt
```

After setup, build the Yocto project using the `entrypoint.sh` script to populate the sstate-cache, or alternatively, manually replace the contents of `.../src/yocto-build/assembly/build/sstate-cache` with your own cache files.

The main script for working with the cache server is:  
`.../src/experiment/cache_server_setuper/manipulate_cache.sh`

#### Running the Experiment
To start the experiment, navigate to the directory:  
`.../src/experiment/`  
and run:
```sh
./main.sh
```

---

### Features of the `./manipulate_cache.sh` Script

1. Show usage/help:
```sh
./manipulate_cache.sh
```

2. Launch the full pipeline:  
Creates and starts containers hosting `sstate-cache`.
```sh
./manipulate_cache.sh start <port> <count_of_servers>
```
Both `<port>` and `<count_of_servers>` are optional. Default values:
- `port = 9000`
- `count_of_servers = 4`

3. Stop and remove all cache containers:
```sh
./manipulate_cache.sh kill
```
