## Instructions for Applying `cachefiles.patch`

1. Move the patch `cachefiles.patch` into `poky/meta/classes-global/`
2. Apply the patch: `patch -p1 sstate.bbclass < cachefiles.patch`
3. Start the build

### Verifying Patch Functionality

0. Apply the patch as above.
1. Launch several (more than one) cache mirrors with valid `index.txt` files inside `sstate-cache`.
   Example line from index:
   `90/69/sstate:sed::4.9:r0::14:9069..._unpack.tar.zst.siginfo`
2. Configure `local.conf` to include your mirrors in `SSTATE_MIRRORS`. Example:
```bitbake
SSTATE_MIRRORS ?= " \
file://.* http://10.138.70.7:8019/sstate-cache/PATH;downloadfilename=PATH \n \
file://.* http://10.138.70.7:8020/sstate-cache/PATH;downloadfilename=PATH \n \
file://.* http://10.138.70.7:8021/sstate-cache/PATH;downloadfilename=PATH \n"
```
Note: Formatting matters. Even one extra/missing character can trigger warnings/errors in BitBake.

3. If everything is configured correctly, the index file will be requested from each mirror first, and cache files will then be downloaded only from the mirrors where they are actually available.

## Results: Signature Check Speedup
A series of experiments measured the time taken to verify signature hashes. Each algorithm (optimized and standard) was run 7 times.

Results:
1) Optimized: ~0.052 sec
2) Unoptimized: ~32.882 sec
Speedup: ~632x
Tested using one HTTP mirror.


Results with More Mirrors:
With 3 mirrors:
1) Optimized: ~0.174 sec
2) Unoptimized: ~67.6 sec

With 15 mirrors:
1) Optimized: ~0.254 sec
2) Unoptimized: ~194.7 sec


## Results: Cache Download Speedup
Scenarios tested:
1) 2 mirrors: first empty, second full
2) 2 mirrors: evenly split cache
3) 15 mirrors: evenly split cache

Scenario 1 (2 mirrors, 1 empty):
1) Optimized: ~176.81 sec
2) Unoptimized: ~186.77 sec

Scenario 2 (2 mirrors, split):
1) Optimized: ~176.69 sec
2) Unoptimized: ~181.46 sec

Scenario 3 (15 mirrors, split):
1) Optimized: ~174.48 sec
2) Unoptimized: ~255.42 sec



## Interpretation of Results

We can see that with the optimized algorithm, the download time stays approximately the same regardless of the number of mirrors. This is because requests are sent directly to the correct mirror, so the number of total requests remains fixed.

In the case of the unoptimized algorithm, scenario 2 was slightly faster than scenario 1 because in scenario 2 the first mirror also contained part of the cache. As a result, only half of the packages required requests to be sent to both mirrors, while the other half were served immediately.

In scenario 3, the total execution time increased significantly. This is because, for each package, requests were sent to mirrors starting from the first up to the *i*-th one, where the *i*-th mirror is the one containing the needed cache.  
So, if the required cache was on the 15th mirror, requests were sent to all mirrors from 1 to 15.
