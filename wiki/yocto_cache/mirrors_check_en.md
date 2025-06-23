## Source Code for Mirror Availability Check

1. In `sstate.bbclass`, the variable `BB_HASHCHECK_FUNCTION = "sstate_checkhashes"` is set. In the `sstate_checkhashes` function, two sets are defined: `found()` and `missed()`, which are later populated with the `tid`s of found and not found tasks, respectively. A `tasklist` is created containing tuples of the form `(tid, sstatefile)`. A message "Checking sstate mirror object availability" is printed (visible at the beginning of a build), and then for each task in `tasklist`, the `checkstatus` method defined in the same file is called.
2. In the `checkstatus` method, for each task a `Fetch` class object is initialized, declared at  
   https://github.com/yoctoproject/poky/blob/28fd497a26bdcc12d952f81436a6d873d81cd462/bitbake/lib/bb/fetch2/__init__.py.  
   In the `Fetch` constructor, the `self.ud` field is populated with `FetchData` class objects (also in the same file) for each url. `FetchData` stores state for a given url. In the `FetchData` constructor, it iterates over the list `methods` (declared in the same file), and for each, it checks whether that method supports the given url. Once a matching method is found, iteration stops.
3. The objects in `methods` are class-method objects, which are subclasses (concrete implementations) of `FetchMethod`. For example, the `Wget` class supports the protocols 'http', 'https', 'ftp', 'ftps'.
4. Then `sstate.bbclass` calls the `checkstatus` method of `Fetch`, which in turn sequentially calls the `checkstatus` and `try_mirrors` methods of the `FetchMethod` class, first for `PREMIRRORS`, then for the original uri, and then for `MIRRORS`. The `try_mirrors` method of `FetchMethod` builds the mirror uri and calls `try_mirror_url`, which returns False if another url should be tried (i.e., the current one failed).

## A Bit About the Hash Server

When BitBake analyzes the inputs for a build task (recipe, inherited classes, relevant conf variables, and inputs from other tasks), it generates an input hash. This is the basis for the shared state (sstate) cache — if the input hash remains unchanged in a future build, BitBake can reuse the previously generated sstate instead of rerunning the task. This greatly speeds up subsequent builds once the cache is populated.

The hash server enhances sstate cache performance:
It maintains a database mapping input hashes to output hashes.
Normally, if a task’s input hash changes, all dependent tasks are re-executed, even if the output is the same. But with a hash server, BitBake can detect if the output is identical and treat two input hashes as equivalent. This lets BitBake skip dependent tasks if sstate data exists for the older input hash — improving cache reuse and reducing build time.

There are three types of hashes:
1. **taskhash** – computed from recipe metadata, task code, and hashes of dependent tasks. Changes in any of those result in a new hash, triggering a rebuild and new hashes downstream.
2. **output hash** – based on the actual outputs of a task that uses shared state; sent to the hash server alongside taskhash. Stored in the server DB for future reuse.
3. **unihash** – initially derived from taskhash, used to track unique task outputs. If enabled, BitBake uses dependencies’ unihashes instead of taskhashes when computing taskhashes.  
   If a task’s input changes, a new taskhash and output hash are generated and sent to the server. If the server determines the outputs are the same, it returns the original unihash.  
   This keeps downstream tasks’ taskhashes unchanged, allowing BitBake to fetch them from sstate instead of rebuilding.  
   In this way, outputs from later tasks in the pipeline can also be reused from sstate.

BitBake uses unihash values to locate sstate cache files.

## General Flow Overview

0. A hash server client runs on the IP:port defined in `BB_HASHSERVE_UPSTREAM`. BitBake will connect to it.  
   This happens in `bitbake/lib/bb/cooker.py` in the `handlePRServ` function. If the client is unreachable, a warning is printed.  
   A `hashserv.db` file is generated on the hash server — it stores the mapping of `output hash ↔ taskhash`.  
   This mapping allows BitBake to detect when output hasn't changed even if input has — enabling sstate reuse.  
   (If taskhash hasn’t changed, hash equivalence isn’t needed — BitBake uses the cache as usual.)

1. In `bitbake/lib/bb/runqueue.py`, the `_execute_runqueue` method of `RunQueue` calls the `prepare()` method of `RunQueueData`.  
   This method:
   - Resolves all dependencies and builds the task execution queue  
   - Computes task hashes and passes them to `sstate_checkhashes`
     - Hashes are generated via `bitbake/lib/bb/siggen.py`, according to `BB_SIGNATURE_HANDLER`
     - First, `taskhash` is computed for each task
     - Then BitBake tries to retrieve `unihash` (a more complex process)
   - These values are used to generate sstate filenames in `sstate_checkhashes` (unihash is used)

2. `sstate_checkhashes` initializes sets `found` and `missed`. Tasks in `found` are retrieved from cache and reused. `missed` tasks are rebuilt.

3. Within `sstate_checkhashes`:
   - BitBake clears `MIRRORS` and loads `SSTATE_MIRRORS` into `PREMIRRORS` — this ensures only `SSTATE_MIRRORS` are checked.
   - A list of all tasks is prepared.
   - A queue of connection cache objects (`FetchConnectionCache`) is created. Its size = `BB_NUMBER_THREADS`, or the tasklist length (whichever is smaller).
   - BitBake uses a `ThreadPoolExecutor(max_workers=nproc)` to check all tasks in parallel using `checkstatus`.  
     The connection pool helps distribute work across threads. (e.g., 24 threads on some configs)

4. In `checkstatus`:
   - A `Fetch` object is created (using a connection pool object)
   - Its `checkstatus()` method is called

5. If a suitable cache is found:
   - `Fetch.checkstatus()` completes silently  
   - Task is removed from `missed` and added to `found`  
   - If all mirrors fail, `FetchError` is raised, caught in `checkstatus`, and the task stays in `missed`

6. Mirror check details:
   - First, `PREMIRRORS` is checked, then original uri, then `MIRRORS`
   - For mirrors: `try_mirrors()` → `build_mirroruris()` returns:
     - `uris`: mirror file URLs
     - `uds`: corresponding `FetchData` objects
   - Each uri is tried with `try_mirror_url()` → internally calls `method.checkstatus()`  
     - If any returns True → no further mirrors are checked  
     - If all fail → exception raised

7. Result:  
   - `found` = setscene tasks (reused from cache)  
   - `missed` = tasks that must be rebuilt

To disable Hash Equivalence:  
```bitbake
BB_SIGNATURE_HANDLER = "OEBasicHash"
```
This disables unihash — tasks are reused from sstate only if their taskhash hasn't changed.

## Diagram Overview

![image](https://github.com/user-attachments/assets/9b26b7b9-0415-4a96-85b8-af3dcab792b7)

## Hash Server Recreation Experiment

To understand how the taskhash ↔ output hash mapping is populated:

1. Observed that `hashserv.db` on the running hash server was 57.3KB
2. Deleted the entire directory and re-created the server using  
   https://github.com/moevm/os_profiling/blob/main/wiki/yocto_cache/setup_OEEquivHash_server.md  
3. A new `hashserv.db` was generated (same 57.3KB), even before any build
4. Inspected the file — found it only had empty DB tables (no hash mappings yet)
   - So, if your file is only ~57.3KB, it means the DB is still empty
5. After a full build, the file size grew to ~2MB — and it did contain useful mappings
6. If you run the server in read-only mode (as per the guide), the DB won’t be populated
7. When a clean build was launched with the server in read-write mode, the server-side DB stayed empty, but the `/build/cache/hashserv.db` file was filled
8. Copying this DB file to the server yielded a working hash server with actual mappings

## Helpful Resources

1. Excellent presentation explaining hash server functionality:  
   https://elinux.org/images/3/37/Hash_Equivalence_and_Reproducible_Builds.pdf
2. Related presentation video:  
   https://www.youtube.com/watch?v=zXEdqGS62Wc
3. Good article on configuring sstate and hash server:  
   https://www.thegoodpenguin.co.uk/blog/improving-yocto-build-time/
