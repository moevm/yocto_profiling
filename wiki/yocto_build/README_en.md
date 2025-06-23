# Yocto Build

This folder contains information related to various aspects of Yocto builds.

* [yocto_system_image_build](./yocto_system_image_build.md) – overview of how, where, and when files are added to the final image; differences between layers and classes  
* [image_deps](./image_deps.md) – list of parameters for the `core-image-minimal` image (packages, kernel configuration)  
* [add_layers](./add_layers.md) – how to add layers  

## Yocto Build Internals

* [yocto_build_deps](./yocto_build_deps.md) – how BitBake processes dependencies; parsing overview  
* [yocto_stat_sources](./yocto_stat_sources.md) – how Yocto collects statistics  
* [task_map](./task_map.md) – steps for creating a custom recipe  
* [directories_sizes](./directories_sizes.md) – what's inside the `build` directory  
* [WORKDIR](./WORKDIR.md) – how to get the `WORKDIR` variable for a recipe  
* [tasks_priority](./tasks_priority.md) – how/where task priorities are set; experiment with `do_compile`/`do_configure`  
* [speed_up_building](./speed_up_building.md) – speeding up builds using network pressure limits and task graph data  

## Yocto Build Statistics

* [logging_build](./loging_building.md) – how to log build output in Yocto  
* [yocto_buildstats](./yocto_buildstats.md) – build statistics analysis  
* [pid-info](./pid-info.md) – how PID logging works  
* [bitbake_pressure_variables](./bitbake_pressure_variables.md) – BitBake pressure variables and disk space monitoring
