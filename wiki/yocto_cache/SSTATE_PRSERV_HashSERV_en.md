# Overview of the [video](https://www.youtube.com/watch?v=fAeZvIm7Ufc&ab_channel=TheLinuxFoundation)
## Covered Topics
Ways to speed up builds:
- using a local cache and configuring the location of downloaded source code
- using source code archives distributed over local networks
- a technology that simplifies version management of packages — PRServ
- build state cache and validation of cached packages using HashServ

## Using Local SSTATE_DIR and DL_DIR
You can specify the same folder location for all builds locally via SSTATE_DIR and DL_DIR.  
For example, if a certain source was downloaded during build A and is also needed for build B, then specifying the same folder path in `local.conf` via the DL_DIR variable will result in the mentioned source not being re-downloaded during build B.

## Using Source Archives Over the Network
DL_DIR from the previous section applies only on the local machine. If a team of people works on builds, it can be useful to create an archive from the source code. It can be hosted either on a local or global network.  
For these two cases, there are separate build variables:
- PREMIRRORS — these mirrors are typically used as local ones. They have higher priority than MIRRORS.
- MIRRORS — typically used as global mirrors. They have lower priority than PREMIRRORS.  

It’s recommended to specify both PREMIRRORS and MIRRORS in the configuration because local mirrors will be checked first, and if nothing is found, then global ones will be checked.

## PRServ
PRServ - Package Revision Service.  
When a project is developed by one person, they assign a revision to each change in the source or package composition like this:  
r0 → change → r1 → change → r2 → ...

But when multiple developers work on the same project, one package may have the same revision number locally for different people while containing different content.  
For example, developer A adds change K to package X, and developer B adds change L to package X. Both assign revision r1 locally, but this causes conflicts and confusion.

Using PRServ makes revision numbering linear:

```
Developer 1 r0 ⇒ ⇒ r3 ⇒ ⇒ ⇒ ⇒ r8
Developer 2    r1 ⇒ ⇒ r4 ⇒ r6
Developer 3       r2 ⇒ ⇒ r5 ⇒ r7
---------------------------------> time
```

## HashServ
SSTATE-CACHE is generated during the build. Using SSTATE-CACHE and HashServ is the most powerful way to speed up the build process.  
SSTATE-CACHE can only be reused if HashServ has validated a specific package using hashing algorithms.  
Hence, a number of tips for working with the project arise to increase the percentage of packages that can be restored from the SSTATE-CACHE:

- the versions of dependent packages in the build where SSTATE-CACHE was generated must closely match those of the target build
- avoid using absolute paths, host-specific settings, or timestamps — these may cause cache invalidation
- the system used to generate SSTATE-CACHE and the one running the target build should be similar — the more identical they are, the higher the cache reuse percentage.  
  To avoid this issue, it’s recommended to use the same system across all projects, such as a specific Ubuntu release or containers.

It’s best to place HashServ on a local network. You can connect one HashServ and multiple SSTATE_MIRRORS to a build.
