List of available patches:
- [buildstats_timestamps.patch](#buildstats_timestampspatch)
- [buildstats_netstats.patch](#buildstats_netstatspatch)
- [pid.patch](#pidpatch)
- [runqueue.patch](#runqueuepatch)
- [poky_dir.patch](#poky_dirpatch)
- [cachefiles.patch](#cachefilespatch)

## buildstats_timestamps.patch

Collection of information in the form of time series. Structure of the collected data.

The resulting time series will be located in the folder `build/tmp/buildstats/{package_name}`.  
The names of the files follow the pattern `{task_name}_timestamps`.

Example contents of the `{task_name}_timestamps` file:
```text
...
Timestamp: 2024-06-25 17:45:13
RAM: VmPeak: 147628 kB, VmSize: 147628 kB, VmHWM: 59252 kB, VmRSS: 59252 kB
IO Stats: rchar: 576639, wchar: 47799, syscr: 53, syscw: 46, read_bytes: 0, write_bytes: 36864, cancelled_write_bytes: 0
...
```

Where:  
- `RAM` — memory usage information:
  - `VmPeak` — peak memory usage
  - `VmSize` — virtual memory size. This is the total address space allocated to the process, including everything it might potentially use.
  - `VmHWM` — peak physical memory usage
  - `VmRSS` — current amount of physical (resident) memory in use by the process

Other possible parameters:
  - `VmData` — data segment size (heap)
  - `VmStk` — stack size
  - `VmExe` — executable code size
  - `VmLib` — memory used by loaded libraries
  - `VmLck` — amount of locked memory (pages that cannot be swapped out, but may be moved within physical memory)
  - `VmPin` — pinned memory (pages cannot be moved or swapped out)
  - `VmPTE` — page table entries size (mapping virtual to physical addresses)
  - `RssAnon` — anonymous memory (not backed by files)
  - `RssFile` — file-backed memory (e.g., code, libs)
  - `RssShmem` — shared memory

- `IO Stats` — input/output info:
  - `rchar` — bytes read from the filesystem
  - `wchar` — bytes written
  - `syscr` — number of read system calls
  - `syscw` — number of write system calls
  - `read_bytes` — actual bytes read from disk
  - `write_bytes` — bytes written to disk
  - `cancelled_write_bytes` — number of canceled write bytes

## buildstats_netstats.patch

As a result, BitBake will add a line like the following to files located in `poky/build/tmp/buildstats/timestamp/recipe/task`:
```text
recieve_speed: 437265162.12 B\sec 
```

## pid.patch

Captures and prints the process PID in the format: `PID: <number>`.

## runqueue.patch

Generates a new file `poky/build/queue` with tasks from the queue that are ready for execution.  
Format of the output:  
`timestamp_buildable: {set of tasks ready to run}`

Example:
`1720020407.2793891_buildable: {'/home/olga/poky/meta/recipes-devtools/qemu/qemu-native_9.0.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/gcc/libgcc_14.1.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/ptest-runner/ptest-runner_2.4.4.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-graphics/xorg-lib/libxdmcp_1.1.5.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-support/libbsd/libbsd_0.12.2.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-extended/xz/xz_5.4.6.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-devtools/file/file_5.45.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/coreutils/coreutils_9.5.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-build_1.2.1.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-support/libunistring/libunistring_1.2.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/gnutls/libtasn1_4.19.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/libedit/libedit_20240517-3.1.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-more-itertools_10.3.0.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-devtools/cmake/cmake-native_3.29.3.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-graphics/xorg-lib/libxcb_1.17.0.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-support/libmd/libmd_1.1.0.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-support/gmp/gmp_6.3.0.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-devtools/python/python3-pygments_2.18.0.bb:do_recipe_qa', '
virtual:native:/home/olga/poky/meta/recipes-devtools/autoconf-archive/autoconf-archive_2023.02.20.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/packagegroups/packagegroup-core-boot.bb:do_deploy_source_date_epoch', 
'virtual:native:/home/olga/poky/meta/recipes-core/ncurses/ncurses_6.5.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-extended/grep/grep_3.11.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-extended/pbzip2/pbzip2_1.1.13.bb:do_recipe_qa', 'virtual:native:/home/olga/poky/meta/recipes-support/libmicrohttpd/libmicrohttpd_1.0.1.bb:do_recipe_qa', 
'virtual:native:/home/olga/poky/meta/recipes-extended/libtirpc/libtirpc_1.3.4.bb:do_recipe_qa', '/home/olga/poky/meta/recipes-core/images/core-image-minimal.bb:do_recipe_qa', 
'/home/olga/poky/meta/recipes-core/sysvinit/sysvinit-inittab_2.88dsf.bb:do_recipe_qa'}`

*Note: output truncated.*

Also generates the file `poky/build/skip`, which contains timestamps and records of tasks that were attempted but ultimately skipped (i.e., BitBake tried to start them but didn’t).

## poky_dir.patch

Once the build starts, recipe parsing times will be logged to `poky/build/recipe_parsing_time.log`.  
Example:
```text
/home/elizaveta/poky/meta/recipes-core/initrdscripts/initramfs-live-boot_1.0.bb: 0.15 seconds
/home/elizaveta/poky/meta/recipes-devtools/opkg/opkg-keyrings_1.0.bb: 0.15 seconds
/home/elizaveta/poky/meta/recipes-graphics/libva/libva-utils_2.20.1.bb: 0.16 seconds
```

To collect per-layer statistics, run `poky/create_parsing_info.py`.  
The output will appear in `poky/build/layer_parsing_time.log`, e.g.:
```text
meta: 113.22 seconds
meta-poky: 0.03 seconds
```

## cachefiles.patch

Changes the mirror polling algorithm during signature (hash) verification.

### How it works:

Each mirror has a file `index.txt` containing paths of files available on that mirror.  
This index is generated automatically when populating `sstate-cache` during a build. The general flow:

1. Start a build to generate the cache. During this, `index.txt` is also generated.  
   This requires a patch to be applied:  
   https://github.com/moevm/os_profiling/blob/ba530d158b228de3f3bbcff3f738fc559a0afa5b/src/index_developments/diff.txt

2. Upload the entire `sstate-cache` folder to the cache server, including the `index.txt` file inside.

3. For subsequent builds with cache server support configured, the behavior changes:

After applying `cachefiles.patch` to `sstate.bbclass`, the logic becomes:

- Iterate through mirrors and attempt to read `index.txt` from each.  
  (The patch currently supports HTTP and FTP protocols.)
- If successful, BitBake parses the index and reuses tasks that are available on the mirror.
- If the `index.txt` file cannot be read (e.g., it's missing or the mirror uses an unsupported protocol), the mirror will be queried using BitBake’s original algorithm.
