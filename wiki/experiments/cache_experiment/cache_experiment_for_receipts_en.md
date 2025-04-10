## Experiment Instructions

To run the experiment:

1. Copy the `meta-user` folder into the `poky` folder.
2. In the `poky/build/conf/bblayers.conf` file, add the `meta-user` path to the `BBLAYERS`. Example:
```
BBLAYERS ?= " \
  /home/user/poky/meta \
  /home/user/poky/meta-poky \
  /home/user/poky/meta-yocto-bsp \
  /home/user/poky/meta-user \
  "
```
3. In the recipe `poky/meta/recipes-core/images/core-image-minimal.bb` (or another image you want to build), add the line:
```
IMAGE_INSTALL += " helloworld"
```
4. Delete the `/poky/build/downloads` folder.
5. Start the build.
6. In the `json.bb` recipe, add the line:
```
SRC_URI += "file://changes.patch"
```
7. Delete the `/poky/build/downloads` folder again.
8. Start the build again.

A part of the experiment’s log file: [log](./console.log)

As a result, after deleting the `downloads` folder and applying the patch, the same tasks were executed during the build as without the patch — that is, `do_fetch`, `do_compile`, etc. Yocto re-downloaded the entire library into the `downloads` folder.

If the `downloads` folder is not deleted, but the patch is used, the library is not re-downloaded — the `do_compile` task starts almost immediately, followed by subsequent tasks.
