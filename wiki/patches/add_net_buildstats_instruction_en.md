# Adding Per-Second Network Stats During Build

To add per-second network statistics and network load calculation (recorded in the file `buildstats/net_pressure.log`) during the build, you need to apply the patch `add_net_buildstats_instruction.patch` to the file `/meta/lib/buildstats.py`.  
The resulting stats will be saved in `reduced_proc_net.log` located in the `build/tmp/buildstats` folder.
