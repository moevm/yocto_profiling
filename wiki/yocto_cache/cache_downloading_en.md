## Downloading sstate cache from mirrors

Currently, BitBake’s classic algorithm collects information about which tasks it can retrieve from the cache, but it does not remember from which mirror it can retrieve a specific task — it starts polling the mirrors again to check for the presence of the particular task.  
Therefore, we want to implement an optimization so that at the moment of polling, when a task is found on a mirror, BitBake remembers from which mirror it will retrieve this task.

The implementation of this optimization can be globally divided into two stages:  
1) Implementing a way for BitBake to “remember” the mapping between a cached task and the mirror from which it will retrieve it  
2) Embedding automatic cache downloading from the correct mirror according to step 1

## Implementation

Since an optimizing patch was already introduced for mirror polling, the implementation of this idea will also be split into two options:  
1) In the classic algorithm  
2) In the optimized algorithm with an index file

Currently, the proposed optimization works in the scenario where an index file is present on the mirror. In other cases, processing falls back to the classic algorithm, so the following discussion only covers the second scenario.

### Algorithm operation:
1. During mirror polling, index files provide information about which cache files are available on which mirrors. This results in a mapping like:  
   `{mirror1: [cachefile1, cachefile2, ..., cachefileN], mirror2: [cachefile2], mirror3: []}`

2. After processing all mirrors where index files were found, the data is converted to this format:  
   `{cachefile1: mirror1, cachefile2: mirror1, ...}`  
   Here, `cachefile_i` are not all the files found in the indexes, but only those required for this specific build — extra information is filtered out and not recorded.  
   This information is written to a file on the client side.  
   (There was an idea to pass this info through BitBake metadata, but that didn’t work out, since BitBake can only see the written data until the end of a function — not beyond it.)

3. In the `pstaging_fetch` function, where cache downloading occurs, the previously saved file is read, the required mirror is selected (if available), and the request goes directly to that mirror.  
   If no info exists for a given file, BitBake falls back to the classic algorithm — it reads the `SSTATE_MIRRORS` variable and checks mirrors one by one.

# Results
1. A test was conducted with two mirrors containing the same, complete cache. On the first mirror, the index file was empty; on the second, it was valid.  
   In `local.conf`, the mirrors were listed in the corresponding order.  
   As a result, requests immediately went to the second mirror, as expected.  
   (In the classic algorithm, requests would have gone to the first mirror first.)

2. An observation was made: in the `fstaging_fetch` function, before calling `download()`, the `checkstatus()` method is called.  
   It turned out that disabling the call to `checkstatus()` caused HEAD-type requests to stop being sent to the cache server — only GET requests were sent instead.  
   The build still completed successfully.  
   That is, previously each mirror received request pairs (first HEAD, then GET), but now only GET requests are sent.  
   Open question for discussion: why are HEAD requests needed, and are they truly necessary if the build succeeds without them?
