## Running the oe-selftest

1. In the file `sstatemirrors.py`, specify:
  - In the variable `SERVER_COUNTS`, the number of servers you want to test with. Each element of the array equals the number of servers, and the array length equals the number of builds to be performed. **The array length must be >= 2, the number of servers per build must be >= 2, and the values should be listed in ascending order of the number of servers.**
  - In the field `SSTATE_CACHE_PATH`, the path to the folder containing the `sstate-cache`; this cache will be distributed among the servers.
  - In the field `HTTP_START_PORT`, the port from which servers will start (i.e., ports from `self.start_port` to `self.start_port + <current_number_of_servers>` will be occupied).
  - In the field `OE_INIT_SCRIPT`, the path to the `oe-init-build-env` file (needed to run the hash server).
  - In the field `HASH_SERVER_WORKDIR`, the path to the folder where the hash server will be started.
  - In the field `LOG_PATH`, the path to the log file with test results.
  - In the field `HASH_SERVER_PORT`, the port of the hash server.

2.
    1) For manual launch:
        - Place the `sstatemirrors.py` file into `poky/meta/lib/oeqa/selftest/cases`.
        - From the `poky` directory run:
           1) `source ./oe-init-build-env`. After this, to run `oe-selftest`, add the line `SANITY_TESTED_DISTROS=""` to the `poky/build/local.conf` file (this applies to running all oe-selftests, not only custom ones).
           2) Run `oe-selftest -r sstatemirrors`. The `-r` flag is needed to run tests; you can also specify the `-K` flag to keep the working directory `build-st` after the tests (this directory is generated during tests alongside `build`; its content is similar to `build`, but `build` is used for builds, and `build-st` is for tests).
    2) To run via `./entrypoint.sh`:
       - From the project root, run:
           1) `./entrypoint.sh by --only-poky` to clone the poky repository.
           2) `./entrypoint.sh st` to run the tests.
