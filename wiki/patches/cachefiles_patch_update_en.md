## Problem
The client needs to retrieve information from cache servers about which cache files are available on the server and maintain the relevance of this information.

### Logic Description Before and After the Patch
Before starting to check mirrors and download caches from them, the client knows which cache files it needs to obtain. A list of such files is compiled, with each file name containing a hash value (signature). Thus, the client will search for a cache file with a specific signature on the server. However, the client does not know from which mirror it can obtain a specific file. Therefore:
- Before the patch: The client would poll all mirrors for each task until it found one with the desired file.
- After the patch: The logic changed as follows: first, the client attempts to retrieve an index file from each mirror, which contains information about which files are available on that mirror. Then, it parses this information, and tasks found on any mirror begin to be downloaded directly from the required mirror. Mirrors from which the index file could not be retrieved are then polled for the remaining tasks using the standard algorithm (as before the patch).

Issues with the Current Approach:
- The index file is requested in its entirety, and it can be very large.
- The index file is currently in txt format.
- The index file needs to be kept up-to-date, which is not currently implemented.
- The client needs to support various protocols; currently, HTTP and FTP are supported.


## Solution Options
1) Using an Index File (Current Approach)
An index file is a file on the cache server containing information about all cache files.

Server-side Logic:
- Creation of the index file
- Maintaining the index file's relevance

Client-side Logic:
- Parsing the index file

Maintaining Index File Relevance:
- Manual Updates:
    Pros: None
    Cons: Requires monitoring the index file's relevance; high probability of errors

- Using Cron Jobs:
    Pros: Automatic updates
    Cons: Possibility of obtaining outdated information between file system updates and cron job execution

- Using inotify:
    Pros: Automatic updates; real-time response to file system changes
    Cons: Limited number of watch descriptors monitoring directory changes (usually 8192); does not work recursively, meaning watch descriptors need to be set for all new directories in sstate-cache

Pros of the Approach: No need to change or extend server logic
Cons of the Approach: The client must download and process a large index file


2) Using an API
Using an API eliminates the need to transfer a large index file, as the server can provide information relevant to a specific build. It also removes the need to worry about the file system's state, as the server can traverse the file system and gather current information during request processing.

Server-side Logic:
- Endpoint to handle client requests

Client-side Logic:
- Parsing the server's response

There are various approaches to determining which updates should be sent to the client. Essentially, they boil down to the client initiating a request for package updates, and the server responding with metadata about available package versions (metadata can include manifests like package.json/requirements.txt, as well as timestamps, hash codes, etc.). The client uses this information to determine which packages need updating and sends requests to update specific packages. In our case, there is no need to introduce an additional versioning system, as the client already knows the hash codes of the files it needs at the time it starts querying the mirrors.

Pros of the Approach: No network load from transferring a large index file; No need to maintain the index file's relevance;
Cons of the Approach: Dependent on a server with a specific API;


## Notes
### Types of Mirrors in Yocto
From the Yocto Project documentation on SSTATE_MIRRORS: 'You can specify a file system directory or a remote URL, such as HTTP or FTP.' Documentation on SSTATE_MIRRORS. However, BitBake also implements many other fetchers: Documentation on fetchers. While I haven't found examples where such URLs are specified in SSTATE_MIRRORS, it is theoretically possible.