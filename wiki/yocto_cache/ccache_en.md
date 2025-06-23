# Ccache

Ccache is a C/C++ compiler cache that speeds up program compilation by caching the results of previous compilations.

## Main advantages of using ccache

* When running commands like `make clean; make`, the entire compilation process starts from scratch, which takes time.  
  Using ccache avoids recompiling code that has already been processed, which significantly speeds up the process.  
  Ccache stores compiled objects and can reuse them if the source code hasn't changed.

* Ccache supports using the same cache for builds in different directories. This is especially useful when working with multiple versions or branches of software.  
  Even if the source code differs slightly, many object files can be reused from the cache, reducing compilation time.

* Ccache is also useful on servers that frequently perform builds to ensure the code compiles without errors.

* Ccache supports sharing the cache between multiple users, which can be especially useful on shared build servers.

## Disadvantages of using ccache

* New compiler versions often introduce features that ccache cannot anticipate.  
  In some cases, ccache has a hard time correctly handling compiler behavior, especially considering backward compatibility with legacy compilers.

* In some cases, using the fastest mode ("direct mode") can lead to false cache hits.

## Using ccache in Yocto

A special class `ccache.bbclass` is provided, which enables the use of ccache in Yocto.  
This class is used to slightly improve build performance.  
However, using this class may lead to unexpected side effects.  
Therefore, it is recommended not to use this class (according to the official [documentation](https://docs.yoctoproject.org/3.3.1/ref-manual/classes.html#ccache-bbclass)).
