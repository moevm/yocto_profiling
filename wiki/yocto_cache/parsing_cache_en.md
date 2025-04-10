# Caching Recipe Parsing in BitBake
BitBake optimizes the build process using a caching mechanism for data obtained during recipe parsing.

## How Parsing Caching Works
- Saving variables: BitBake saves the values of the variables it is interested in and that are actually used during the build (intercepting `getVar` calls) and does not save the rest of the information. Experience shows that re-parsing metadata is faster than writing and reloading all the information to disk.
- Cache validity check:
	- if the file does not exist or its modification time (mtime) differs from the one saved in the cache, the cache is considered invalid
	- for each dependent file, it checks whether it exists and whether its modification time has changed. If the dependent file is missing or changed, the cache is considered invalid.
	- if the file has checksums, it checks whether the files from the checksum list exist and whether they have changed. If there are mismatches, the cache is considered invalid.
	- it compares current appends with those saved in the cache. If they differ, the cache is considered invalid.
- `bb_cache.dat` is used to store the cache
- If the cache is valid, BitBake loads cached recipe information instead of re-parsing, which significantly saves time.

## Experiment with Modifying Recipes
### Purpose of the Experiment
To check the system’s behavior when modifying a recipe that many other recipes depend on, and a recipe that no other recipes depend on.
### Results of the Experiment
When modifying a recipe that many other recipes depend on, or a recipe that no other recipes depend on, BitBake does not re-parse any other recipes except for the modified one. For both cases, the result is the following:
```
Loading cache: 100% |##############################################################| Time: 0:00:00
Loaded 1844 entries from dependency cache.
Parsing recipes: 100% |############################################################| Time: 0:00:00
Parsing of 912 .bb files complete (911 cached, 1 parsed). 1844 targets, 50 skipped, 0 masked, 0 errors.
```
