# Summary document describing caching in BitBake and Yocto, and how to work with it

### Frequently Used Terms
**Cache** – storage of intermediate results created during the build, such as compiled object files, packages, or even complete images. This allows speeding up subsequent builds by using saved results instead of re-executing all build steps.

**Hashing** – the use of hash functions to identify and verify the integrity of cached data. The hash function computes a unique hash value for each cache object, and this value is saved along with the artifact in the cache. When reusing the artifact, the hash function recomputes the hash and compares it to the saved one to ensure the artifact has not changed or been corrupted.

**Cache server** – a server used to store and serve cached data.

**BitBake hash server** – a server used to store and serve hash values for data created during the BitBake build. The BitBake hash server is used to verify artifact integrity, prevent re-building of unchanged artifacts, and ensure build reliability and security.

### Cache Location (what is saved, where it's located by default, and how to configure it)
By default, all cache is located in the poky/build folder:
1) state cache – poky/build/sstate-cache/
2) download cache – poky/build/downloads/

These are the default values, but they can be customized by specifying in poky/build/conf/local.conf:
1) `SSTATE_DIR = "abs_path"` – path to the state cache (you can use `${TOPDIR}`)
2) `DL_DIR = "abs_path"` – path to the download cache (you can use `${TOPDIR}`)

More info can be found [here](./cache_locate.md)

### Sharing Local Cache for Local Builds
To share cache from an old build with a new one, you can specify paths to existing cache and downloads folders. You can also set `BB_NO_NETWORK = "1"` in poky/build/conf/local.conf — this strictly tells the build to use only local data, and not to download anything.

More details are in [this file](./local_cache_share.md)

### Setting Up Cache Server and Hash Server Locally + Configuring a New Build to Use These Servers via Mirroring
In the suggested solutions, a simple HTTP Python server is used to serve build and download cache.  
How to set up a simple HTTP cache server without a hash server is described [here](./simple_http_cache_mirror.md)

However, using a cache server without a hash server provides less performance gain than using both together.  
How to set up an OEEquivHash cache server is described [here](./setup_OEEquivHash_server.md)

### General Theoretical Information on Caching
More abstract/general information on caching is available [here](./yocto_cache.md)
