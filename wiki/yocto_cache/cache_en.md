## Contents of the /poky/build/cache directory

The Yocto documentation states that the /poky/build/cache directory contains internal files used by the build system.

Importantly, the /poky/build/cache directory contains a text file called sanity_info, which holds information such as the values of TMPDIR, SSTATE_DIR, as well as the host distribution name and version.

It also contains a file called bb_persist_data.sqlite3, which is a centralized storage of data that can be accessed by other threads/tasks in the future.

Link to Yocto documentation: https://docs.yoctoproject.org/ref-manual/structure.html  
Link to source code file with comments: https://github.com/openembedded/bitbake/blob/97ffe14311407f6e705ec24b70870ab32f0637b9/lib/bb/persist_data.py#L241
