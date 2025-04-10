# Adding Network Load Limit During Build

To speed up package builds in the Yocto Project, you can limit network load during the build. To do this:

1. Apply the patch  
   [`add_net_buildstats.patch`](https://github.com/moevm/os_profiling/blob/1aa71b1f78111d2f731c0d86d5c1c60c3e091860/src/yocto-patches/add_net_buildstats.patch)

2. Then apply the patch  
   `add_net_limit.patch`.
