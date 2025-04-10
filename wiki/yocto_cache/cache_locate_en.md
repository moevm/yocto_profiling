## Local Cache Location

All local cache is stored in `poky/build`

### Build Process Cache  
The build process cache is located in the folder `poky/build/sstate-cache/`

### Build Tools Cache  
The cache for build tools (utilities used during the build) is located in the folder `poky/build/cache/`

### Downloaded Source Code  
Downloaded source code and binary files are located in `poky/build/downloads/`

---

## Configuration Parameters

This is the default layout — it can be configured via the `poky/build/conf/local.conf` file.  
This file is generated automatically.

### Let’s see where exactly it’s created.

`oe-init-build-env` calls `oe-setup-builddir`, and it’s in this file that `local.conf` is populated.

---

### Editing the local.conf File

We can manually set the location of local [cache](#local-cache-location)

Let’s map variables to types of cache:  
- `DL_DIR` – **Downloaded source code**  
- `SSTATE_DIR` – **Build process cache**

In the same file, you can also configure a remote cache server mirror using the `SSTATE_MIRRORS` variable.

---

## Instructions for Running an Experiment with local.conf

### Creating the build folder and configuration

In a clean Poky repository (or if not clean, run `rm -rf build` to reset), execute:  
```bash
source oe-init-build-env
```

This will place you inside a new `build` folder where the `conf` directory is created with the configuration files.

---

### Configuring Parameters

Open the `local.conf` file and add lines like:  
```bitbake
DL_DIR = "${TOPDIR}/experiment_downloads_experiment"
SSTATE_DIR = "${TOPDIR}/experiment_sstate-cache_experiment"
```

---

### Starting the Build:

To launch the build, run the following from the `poky/build` directory:  
```bash
bitbake <image>
```

Where `<image>` is the target you want to build (e.g., `core-image-minimal`).

Let’s observe which folders get created:

![Screenshot from 2024-04-11 15-04-16](https://github.com/moevm/os_profiling/assets/90711883/c34b58c2-57f2-444e-bd20-ba849e80e2f6)

As you can see, the folders we specified in the configuration are created.

---

### Forced Shutdown and Build Restart

Let’s conduct an experiment — forcibly stop the build and then restart it:

![Screenshot from 2024-04-11 15-09-31](https://github.com/moevm/os_profiling/assets/90711883/f0ec8f04-ae88-4614-9c25-ed180179ed30)

We can see that the cache is being reused (i.e., there’s no other place in the project where cache folder locations are defined) — this is a good sign.
