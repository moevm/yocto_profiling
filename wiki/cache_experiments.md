### Тест пересборки при уже созданном образе
1) При наличии собранного образа и без внесения изменнеий в сборку - сборка не происходит
```
Loading cache: 100% |##############################################################################################################################| Time: 0:00:01
Loaded 1849 entries from dependency cache.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.7.2"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "4.3+snapshot-9c1d226fadf7f88ed4e1c0a8d21b3f97bc877eb2"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta                 
meta-poky            
meta-yocto-bsp       = "master:9c1d226fadf7f88ed4e1c0a8d21b3f97bc877eb2"

Sstate summary: Wanted 1 Local 0 Mirrors 0 Missed 1 Current 4676 (0% match, 99% complete)#############################################             | ETA:  0:00:00
Initialising tasks: 100% |#########################################################################################################################| Time: 0:00:13
NOTE: Executing Tasks
NOTE: Tasks Summary: Attempted 9509 tasks of which 9509 didn't need to be rerun and all succeeded.
```
2) если полностью удлаить /build - будет полная пересборка на основе кэша
```
Loading cache: 100% |#############################################################| Time: 0:00:00
Loaded 1849 entries from dependency cache.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "2.7.2"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "4.3+snapshot-9c1d226fadf7f88ed4e1c0a8d21b3f97bc877eb2"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta                 
meta-poky            
meta-yocto-bsp       = "master:9c1d226fadf7f88ed4e1c0a8d21b3f97bc877eb2"

Sstate summary: Wanted 4558 Local 0 Mirrors 0 Missed 4558 Current 119 (0% match, 2% complete)0:00
Initialising tasks: 100% |########################################################| Time: 0:00:02
NOTE: Executing Tasks
```

Видно, что в кэше bitbake находится только 1849 записей
