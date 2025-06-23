## Setting Up Cache Mirrors [Without Using a Hash Server]
### Preparation
To connect to a remote cache server, you must first set up that remote cache server according to [this instruction](./setup_http_server.md).

### Configuring Remote Build Using a Simple Mirror
You need to perform the standard steps for starting a build:
1) cd poky  
2) source oe-init-build-env  
3) Modify the file `/poky/build/conf/local.conf` as follows:
```sh
MACHINE ??= "qemux86-64" 
DL_DIR ?= "${TOPDIR}/downloads"
SSTATE_DIR ?= "${TOPDIR}/sstate-cache"
DISTRO ?= "poky"
PACKAGE_CLASSES ?= "package_ipk"
# everything above is not important in the context of mirror setup


SOURCE_MIRROR_URL ?= "\
file://.* http://127.0.0.1:8000/downloads/PATH;downloadfilename=PATH"

SSTATE_MIRRORS ?= "\
file://.* http://127.0.0.1:8000/sstate-cache/PATH;downloadfilename=PATH"


# everything below is not important in the context of mirror setup, but will be important later for setting up a hash server
BB_HASHSERVE = "auto"
BB_SIGNATURE_HANDLER = "OEEquivHash"
CONF_VERSION = "2"
```

**Important note!**  
`file://.* http://127.0.0.1:8000/downloads/PATH;downloadfilename=PATH` ← this line will work **for me**, because my cache server is running on the local host (hence the IP 127.0.0.1) on port 8000 (hence port 8000), and the `downloads` folder is located right at the root of the server (that’s why I write `downloads` or `sstate-cache` immediately after the IP and port). If your server’s filesystem structure is different — you need to specify the full path from the server root to the required folders.

### Verifying Mirror Operation
With the described settings, start the build with the command `bitbake -k core-image-minimal` (or another image).  
If everything is configured correctly (in terms of server and mirrors), then during the run, you will see logs like this:  
![Screenshot from 2024-04-26 14-16-42](https://github.com/moevm/os_profiling/assets/90711883/b7df7be5-7894-4407-b670-1b1225569f5e)

Let’s go over what’s shown:
1) We enabled hashserver-related options, but did not launch it and did not specify which machine and port it is on. Logs reflect this:
```
WARNING: You are using a local hash equivalence server but have configured an sstate mirror. This will likely mean no sstate will match from the mirror. You may wish to disable the hash equivalence use (BB_HASHSERVE), or use a hash equivalence server alongside the sstate mirror.
```
2) Since we didn’t launch the hash server — the prebuilt dependencies didn’t load, but the compiled sources, source downloads, etc., did. That’s why the logs show:
```
Sstate summary: Wanted 1781 Local 0 Mirrors 882 Missed 899 Current 0 (49% match, 0% complete)
```
It shows that 882 cached tasks were loaded from mirrors, and 899 were missed (because the hash server was not configured).
