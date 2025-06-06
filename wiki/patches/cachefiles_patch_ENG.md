# cachefiles.patch
## Description of Changes
When building an image, the system uses a cache to avoid re-running tasks. When the ` sstate-cache ` directory is empty or the required cache file is missing, the system searches for files on cache mirrors defined in ` SSTATE_MIRRORS `. However, the system's lack of information about the distribution of cache files among cache mirrors results in requests for files being sent to all specified cache mirrors. This increases the number of requests, especially if the number of mirrors is large. The patch addresses this issue by pre-fetching index files from each cache mirror before checking for the presence of cache files. The index file contains data about the contents of the cache mirror, allowing the system to send requests directly to the relevant cache mirrors, reducing the overall number of requests and making them independent of the number of cache mirrors specified in the configuration.

## Behavior Types Based on Index File Presence, Validity, and Invalidity
The patch supports two operating modes: full trust mode and recheck mode. The mode selection is done by setting the ` RELY_ON_INDEX_FILES ` variable in ` local.conf `. If this variable is set to "1", the trust mode is enabled, where only the information from the index files is used. Otherwise, if the variable is not set or has a different value, the recheck mode is activated.

The patch's algorithm includes the following steps:
1. Sending requests to retrieve index files from all cache mirrors specified in ` SSTATE_MIRRORS `
    - 1.1. If the request is successful, the information about the cache files from the mirror is considered, and the mirror is added to the list of checked mirrors.
    - 1.2. If the request is unsuccessful, nothing happens.
2. Analyzing the information about cache files present on the cache mirrors to match the required build tasks. Complete information is gathered about which tasks are found on the cache mirrors through the analysis of index files, and on which mirrors they are located. Also, sets of found and not found tasks are collected to search for the remaining tasks not found (the specific algorithm depends on the mode).
3. If trust mode (` RELY_ON_INDEX_FILES == "1" `) was set, then:
    - 3.1. If some of the cache mirrors specified in ` SSTATE_MIRRORS ` remain unchecked (e.g., the index file was missing on the mirror), these mirrors are then checked using the classic algorithm for the presence of cache files corresponding to the not found tasks. The found tasks are added to those already found using the index files.
    - 3.2. If all mirrors were successfully checked, the mirrors checking process ends.
4. If recheck mode was set, then:
    - 4.1. If some tasks remain not found, the classic algorithm will send requests to search for cache files corresponding to these tasks on all cache mirrors specified in ` SSTATE_MIRRORS `. Thus, the situation where the index file is somewhat outdated (a cache file appeared on the cache mirror, but there is no information about it in the index file) is taken into account.
    - 4.2. If all tasks are found, or all requests for not found tasks are completed, the algorithm ends.
5. Cache file download stage:
    - 5.1. If information about the location of the desired cache file is available, the request is sent to the corresponding cache mirror.
        - 5.1.1. If the cache file is found on the specified cache mirror, it is downloaded.
        - 5.1.2. If the request to the required cache mirror is unsuccessful for some reason, all cache mirrors specified in ` SSTATE_MIRRORS ` are then queried. Thus, the situation where the cache mirror became unavailable after the mirrors checking, but the necessary cache file can be obtained from another cache mirror, is taken into account.
    - 5.2. If there is no information about the location of the desired cache file, requests will be sent to all cache mirrors from ` SSTATE_MIRRORS ` according to the classic algorithm.


## Architecture of Changes
1. Addition of the ` compose_index_files ` function:
    - Implemented in the ` meta/classes-global/sstate.bbclass`  class to send requests for retrieving index files from cache mirrors.
    - The call to this function is integrated into the process before starting the hash check (` BB_HASHCHECK_FUNCTION `) in the ` bitbake/lib/bb/runqueue.py ` file.

2. Modification of the ` sstate_checkhashes ` function (` meta/classes-global/sstate.bbclass `):
    - The function now analyzes the information about cache files obtained from index files and forms a new data structure — ` file_mirror_map `. This structure stores information about the distribution of cache files across cache mirrors and is written to the storage.
    - The logic for handling tasks not found using index files varies depending on the selected mode and is described in the section "Behavior Types Based on Index File Presence, Validity, and Invalidity" (points 3, 4).
3. Use of the ` file_mirror_map ` structure:
    - After formation and saving, the structure is then read in bitbake/lib/bb/runqueue.py for passing to the bitbake-worker function.
    - In ` /bitbake/bin/bitbake-worker `, the ` file_mirror_map ` structure is received and used to pass information about the location of cache files. This ensures the availability of information about the location of cache files during subsequent downloads.
4. Modification of the pstaging_fetch function (` meta/classes-global/sstate.bbclass `):
    - If the location of the cache file is known, the request is sent directly to the cache mirror specified in ` file_mirror_map `.
    - If the location is unknown, requests are sent in order to all cache mirrors according to the ` SSTATE_MIRRORS`  list.

## Enabling Patch Functionality
1. Apply the patch.
2. Add the line  `SSTATE_MIRRORS_INDEX_FILES = "1" ` to ` local.conf ` to enable support for index files.
3. Additionally, to activate trust mode, add ` RELY_ON_INDEX_FILES = "1" `.


## Patch Limitations
1. Retrieval of the index file is only available over http/https and ftp protocols.
2. The patch does not consider situations where cache mirrors with the desired cache file were available at the time of checking but became unavailable when attempting to retrieve the cache file. Additionally, it does not account for situations where index files indicate the presence of a file that is actually missing from all cache mirrors (if it exists on at least one cache mirror, it will be retrieved).


## Index File Update
The person deploying the cache mirror is responsible for updating/refreshing the index file.