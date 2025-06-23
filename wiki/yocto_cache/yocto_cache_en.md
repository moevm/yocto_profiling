## Yocto/BitBake caching overview

### General Information
- In Yocto (BitBake), the following are cached: source files, intermediate build results (including results from previous builds), dependencies, and pre-downloaded ready-made utilities (those used in the build but not compiled from source, instead downloaded as ready-made tools).
- It is possible to organize cache servers (i.e. a defined location where some components are prebuilt and cached); in this case, the build must be configured accordingly — how to do this is described in [source 1](https://docs.yoctoproject.org/overview-manual/concepts.html#shared-state-cache). A specific case would be a local build in directory A, with directory B accessing its cache for building.
- By default, the cache is loaded from the `sstate-cache` folder (when rebuilding an image).
- During image rebuilds, hash sums of cached data are compared — this determines whether to reuse previous build cache.
- The cache is generated progressively during the build — task is completed → it is cached.
- Flags can be used to configure which data should be cached.

- Incremental build = rebuild or build using external cache.

### Locating and Analyzing Recipes (Tasks)
In the setup phase, BitBake sets the `BBFILES` variable and uses it to generate a list of tasks along with `.bbappend` files to be executed.  
BitBake analyzes each recipe and append file from `BBFILES`, storing variable values into memory. Append files are applied in the order listed in `BBFILES`.

For each recipe file, a new copy of the base configuration is created, and the task is then analyzed line by line. For each `inherit` statement, BitBake finds and analyzes the corresponding `.bbclass` file using `BBPATH`.  
Finally, BitBake sequentially processes all append files found in `BBFILES`. By convention, the task name is used to determine metadata parts.

By the end of recipe parsing, BitBake has a list of defined tasks and a data structure of key-value pairs and task dependency info.  
Not all this information is needed, and only a small portion is actually used for build decisions. BitBake caches only the required values, discarding the rest. Experience shows that it's faster to reparse metadata than to write and reload it from disk.

Whenever possible, subsequent BitBake commands use the cached recipe data.  
Cache validity is determined by calculating the checksum of the base configuration (`BB_HASHCONFIG_WHITELIST`) and comparing it with the stored value.  
A matching checksum means the task and class files haven’t changed, so BitBake can reuse them.

### Working with Hash Sums (Signatures)
A checksum is a unique signature of the task’s input and helps determine whether to re-run the task.  
Since any input change causes a task to rerun, BitBake must detect those changes.

For shell tasks, this is fairly simple: BitBake generates run scripts for each task, and the checksum reflects any input changes.  
However, not all data is included in the checksum. For example, the working directory path should not affect the final package output.  
A basic exclusion method is to assign it a fixed value. BitBake goes further, using `BB_HASHBASE_WHITELIST` to specify variables that should not influence the checksum.

Another problem arises when a run script contains functions that are never called.  
The incremental build logic analyzes function dependencies and trims the run script to the minimum required set. This improves clarity and avoids unnecessary variability.

A similar approach applies to Python tasks: the system detects which variables a Python function accesses, and what other functions it calls.  
Incremental build logic includes code to identify these dependencies and uses them to compute the checksum.

As with working directories, you might want to ignore some dependencies.  
This is done via:

```
PACKAGE_ARCHS[vardepsexclude] = "MACHINE"
```

— meaning `PACKAGE_ARCHS` does not depend on `MACHINE`, even if it references it.

To force inclusion of dependencies that BitBake might miss:

```
PACKAGE_ARCHS[vardeps] = "MACHINE"
```

In rare cases, BitBake can't detect Python dependencies. In debug mode (`-DDD`), BitBake emits warnings when it fails to resolve them.

So far we’ve discussed only direct input to tasks. This is known as the **basehash**.  
But there’s also **indirect input** — already-built elements in the build directory.

The task’s final checksum (signature) includes the `basehash` and hash values of all dependent tasks.  
Which dependencies are included is determined by policy — the result is a task checksum incorporating the `basehash` and its dependencies.

You can influence hash values through config. For example, this OE expression in BitBake config excludes global variables from hash calculations:

```
BB_HASHBASE_WHITELIST ?= "TMPDIR FILE PATH PWD BB_TASKHASH BBPATH DL_DIR \
SSTATE_DIR THISDIR FILESEXTRAPATHS FILE_DIRNAME HOME LOGNAME SHELL TERM \
USER FILESPATH STAGING_DIR_HOST STAGING_DIR_TARGET COREBASE PRSERV_HOST \
PRSERV_DUMPDIR PRSERV_DUMPFILE PRSERV_LOCKDOWN PARALLEL_MAKE \
CCACHE_DIR EXTERNAL_TOOLCHAIN CCACHE CCACHE_DISABLE LICENSE_PATH SDKPKGSUFFIX"
```

Note: the working directory isn't listed — it’s part of `TMPDIR`.

Hash inclusion rules based on dependency chains are more complex and usually implemented in Python.  
See `meta/lib/oe/sstatesig.py` — it contains two examples and shows how to add your own logic.

This file defines the two main OpenEmbedded-Core signature generators: `OEBasic` and `OEBasicHash`.  
By default, BitBake uses a no-op handler `noop`, which behaves like older versions.  
OE-Core uses `OEBasicHash` by default (set in `bitbake.conf`):

```
BB_SIGNATURE_HANDLER ?= "OEBasicHash"
```

Unlike `OEBasic`, `OEBasicHash` includes task hashes in stamp files.  
So any metadata change that affects a task’s hash triggers a rebuild — no need to manually bump PR values.

This makes changes propagate through the build automatically.

Available signature-related variables:
- **BB_BASEHASH_task-taskname** — base hashes for each task in a recipe;
- **BB_BASEHASH_filename:taskname** — base hashes for dependent tasks;
- **BBHASHDEPS_filename:taskname** — task dependencies;
- **BB_TASKHASH** — current running task’s hash.

Use the `-S` option to debug signatures.

Modes:
- `none` — logs signature info to `STAMPS_DIR`
- `printdiff` — finds matching signature in (e.g. sstate-cache) and runs `bitbake-diffsigs` to show where things diverged

Future versions may include more signature handlers.

For more on checksum metadata, see Section 3.

### Setscene
The setscene process lets BitBake reuse previously built components without rebuilding from scratch.  
For this, reliable compatibility info is needed. The previously discussed signatures are perfect for this.

If the signatures match, the object is reused.

BitBake replaces the result of a task with a prebuilt version using the setscene process.

When BitBake is requested to build a target, it first checks for available cached data for that or dependent tasks.  
If such data exists, BitBake attempts to use it.

It starts by calling the function defined in `BB_HASHCHECK_FUNCTION` with a list of tasks and hashes for the build plan.  
This function returns the list of tasks with reusable results.

Then BitBake executes each task’s `_setscene` version — these either return the required output or fail.

Sometimes, a component includes multiple tasks (e.g., a compiled toolchain). BitBake runs `BB_SETSCENE_DEPVALID` for each successful `_setscene` task to determine whether its dependencies should also be reused.

After all `_setscene` tasks finish, BitBake calls the function in `BB_SETSCENE_VERIFY_FUNCTION2` with the list of "covered" tasks.  
Metadata can adjust this list or request that specific tasks be rebuilt, regardless of `_setscene` success.

Setscene metadata is described in Section 3.12.

### Setscene Metadata and Task Checksums
BitBake uses checksums (signatures) with setscene to decide which tasks to run. This process is shown using OE metadata.

Checksums are stored in the `STAMP` directory.

Use `bitbake-dumpsigs` to view signature data — this helps verify input used to generate signatures.  
For example, you can inspect the `do_compile` sigdata of a C app (e.g. bash) and see that the `CC` variable is part of the hash input — changing it invalidates the stamp and triggers rebuild of `do_compile`.

Key variables:
- **BB_HASHCHECK_FUNCTION** — name of function used by setscene to check hash values
- **BB_SETSCENE_DEPVALID** — function BitBake uses to determine whether to fetch a setscene dependency
- **BB_SETSCENE_VERIFY_FUNCTION2** — function to validate covered task list before running normal tasks
- **BB_STAMP_POLICY** — mode for comparing timestamps in stamps
- **BB_STAMP_WHITELIST** — stamp files to inspect in whitelist mode
- **BB_TASKHASH** — hash of the currently running task
- **STAMP** — base path for creating stamps
- **STAMPCLEAN** — base path for creating stamps with patterns for cleanup

### Downloading + Mirroring
Fetching sources in BitBake involves multiple stages. The fetcher performs:
- downloading (possibly from cache)
- unpacking to a specified location (possibly patched)

Example fetch code:
```python
src_uri = (d.getVar('SRC_URI') or "").split()
fetcher = bb.fetch2.Fetch(src_uri, d)
fetcher.download()
```

This creates a fetcher instance using URLs from `SRC_URI`.

Unpacking:
```python
rootdir = l.getVar('WORKDIR')
fetcher.unpack(rootdir)
```

This unpacks downloaded files into `WORKDIR`.

The variables `SRC_URI` and `WORKDIR` aren't hardcoded — different fetchers might use other names.

The `sstate` mechanism also uses the fetch module.

During download(), BitBake searches for source files in order:
1. **PREMIRRORS**
2. **SRC_URI**
3. **MIRRORS**

Each URL is passed to the appropriate handler (e.g., wget, git).

Example:
```
http://git.yoctoproject.org/git/poky;protocol=git
git://git.yoctoproject.org/git/poky;protocol=http
```

The first fails (wget can't handle Git); the second works (Git understands HTTP transport).

Mirror examples:
```
PREMIRRORS ?= "\
bzr://.*/.* http://somemirror.org/sources/ \n \
cvs://.*/.* http://somemirror.org/sources/ \n \
git://.*/.* http://somemirror.org/sources/ \n \
hg://.*/.* http://somemirror.org/sources/ \n \
osc://.*/.* http://somemirror.org/sources/ \n \
p4://.*/.* http://somemirror.org/sources/ \n \
svn://.*/.* http://somemirror.org/sources/ \n"
MIRRORS =+ "\
ftp://.*/.* http://somemirror.org/sources/ \n \
http://.*/.* http://somemirror.org/sources/ \n \
https://.*/.* http://somemirror.org/sources/ \n"
```

BitBake supports Git→HTTP mirror mapping as tarballs.  
Downloaded (non-local) files are stored in `DL_DIR`.

Integrity is critical. BitBake can verify SHA256/MD5:
```
SRC_URI[md5sum] = "value"
SRC_URI[sha256sum] = "value"
```
Or directly in the URI:
```
SRC_URI = "http://example.com/foo.tar.bz2;md5sum=abc..."
```

For multiple URLs:
```
SRC_URI = "http://example.com/foo.tar.bz2;name=foo"
SRC_URI[foo.md5sum] = abc...
```

BitBake places a `.done` stamp in `DL_DIR` to avoid re-downloading.

If `BB_STRICT_CHECKSUM` is set, mismatches cause errors.

Use `BB_NO_NETWORK` to force offline-only builds — useful for mirror verification.

### Unpacking Downloaded Data
BitBake unpacks all non-Git URLs using a unified method.

You can control unpacking via URL parameters:
- `unpack=0` — disables unpacking
- `dos=1` — applies DOS line endings (for .zip, .jar)
- `basepath=` — strips leading paths from archive
- `subdir=` — unpacks into a subfolder

BitBake handles `.Z`, `.z`, `.gz`, `.xz`, `.zip`, `.jar`, `.ipk`, `.rpm`, `.srpm`, `.deb`, `.bz2`, and combinations.

Git uses its own optimized unpacking — typically cloning into a directory with symlinks to Git metadata.

### Useful Material

**Proper cache cleanup**: [link](https://docs.yoctoproject.org/dev-manual/disk-space.html#purging-obsolete-shared-state-cache-files)

**Cache archives**: [link](https://git.yoctoproject.org/)

### Example

Example with image and description: [link](https://docs.yoctoproject.org/overview-manual/concepts.html#bitbake-tasks-map)

### Sources
Source 1 [En]: https://docs.yoctoproject.org/overview-manual/concepts.html#bitbake-tasks-map  
Source 2 [En]: https://docs.yoctoproject.org/overview-manual/concepts.html#shared-state-cache  
Source 3 [En]: https://wiki.yoctoproject.org/wiki/TipsAndTricks/Understanding_what_changed_(diffsigs_etc)  
Source 4 [En]: https://docs.yoctoproject.org/bitbake/  
Source 5 [Ru]: https://www.protokols.ru/WP/wp-content/uploads/2019/12/BitBake-User-Manual.pdf  
