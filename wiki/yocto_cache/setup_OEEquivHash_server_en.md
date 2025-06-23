# Creating a Hash Server
Run the command `. poky/oe-init-build-env` to be able to use bitbake

Where to launch the server — as far as I understand, is not that important, but I create it in a separate folder:  
`bitbake-hashserv -r -b <ip>:<port>` — the `-b` flag allows specifying the IP and port. If you leave `<ip>` empty and only use `:<port>`, the server will launch on localhost.

During this, a `hashserv.db` file is created.  
### What is it for?
By default, a local hash server is used — it verifies signatures and validates the build cache packages from the local `sstate-cache` folder. This validation takes some time, so BitBake provides the ability to use external hash servers for cache validation.  

However, if we use cache mirrors, the local (default) BitBake hash server does not handle them. If we enable mirrors without configuring a hash server, a warning will appear:

> [!WARNING]  
> "WARNING: You are using a local hash equivalence server but have configured an sstate mirror. This will likely mean no sstate will match from the mirror. You may wish to disable the hash equivalence use (BB_HASHSERVE), or use a hash equivalence server alongside the sstate mirror."

Approximate translation of this warning:  
> [!WARNING]  
> "WARNING: you are using a local hash server but have configured an sstate cache mirror. Most likely, this means that no state will match from the mirror. You may want to disable hash equivalence (BB_HASHSERVE), or use a hash equivalence server alongside the sstate mirror."

There are two key points in this message:  
1) maybe we don’t want to compare signatures and essentially want to do a build “from scratch”  
2) maybe we are building on the same machine where the cache is stored, in which case we can specify a local path to that cache

> [!IMPORTANT]  
> Conclusion:  
> If we are setting up a cache server that should potentially work remotely — we must also create a hash server that will compare signatures of cached packages.

### A Bit About Signature Handlers
Yocto supports the following `BB_SIGNATURE_HANDLER` options:  
1. `noop` — [SignatureGenerator(object)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L71) — a minimal class that does almost nothing  
2. `basic` — [SignatureGeneratorBasic(SignatureGenerator)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L218) — inherits from `noop`; developers say it's slow, but useful for debugging  
3. `basichash` — [SignatureGeneratorBasicHash(SignatureGeneratorBasic)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L499) — inherits from `basic`; used as a parent for `TestEquivHash`, `OEBasicHash`, `OEEquivHash`  
4. `TestEquivHash` — [SignatureGeneratorTestEquivHash(SignatureGeneratorUniHashMixIn, SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/bitbake/lib/bb/siggen.py#L892) — a mock class for testing  
5. `OEBasicHash` — [SignatureGeneratorOEBasicHash(SignatureGeneratorOEBasicHashMixIn, bb.siggen.SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/meta/lib/oe/sstatesig.py#L316) — validates package integrity  
6. `OEEquivHash` — [SignatureGeneratorOEEquivHash(SignatureGeneratorOEBasicHashMixIn, bb.siggen.SignatureGeneratorUniHashMixIn, bb.siggen.SignatureGeneratorBasicHash)](https://github.com/yoctoproject/poky/blob/yocto-5.0.1/meta/lib/oe/sstatesig.py#L319) — validates integrity and ensures that equivalent packages produce the same hash so we don’t have to rebuild them. Learn more about equivalence [here](https://docs.yoctoproject.org/5.0.4/overview-manual/concepts.html?highlight=oeequivhash#hash-equivalence).

It is recommended to use `OEEquivHash`.

# Remote Build Configuration and Building

### Configuration in Yocto (5.0)

> [!NOTE]  
> Suggested approach — try to make the `local.conf` files in your build as similar as possible to the one from which the cache was exported. This increases signature match. At the end of the file, before the line `CONF_VERSION = "2"`, add the following config:

```sh
SOURCE_MIRROR_URL ?= "\
file://.* http://10.138.70.218:8888/downloads/PATH;downloadfilename=PATH"

SSTATE_MIRRORS ?= "\
file://.* http://10.138.70.218:8888/sstate-cache/PATH;downloadfilename=PATH"

BB_HASHSERVE = "auto"  
BB_HASHSERVE_UPSTREAM = "10.138.70.218:8686"  
BB_SIGNATURE_HANDLER = "OEEquivHash"  
```

To simplify working with config files, here’s a Python script that removes comments from the config:

```py
import os
def remove_comments(filename):
    temp_filename = filename + ".tmp"

    with open(filename, "r") as input_file, open(temp_filename, "w") as output_file:
        for line in input_file:
            if not line.startswith("#"):
                output_file.write(line)
    os.rename(temp_filename, filename)

if __name__ == '__main__': 
    remove_comments("local.conf")
```

### Build
If the configuration is correct, there should be no problems with the build.  
Run the build using `bitbake <target>`  
Logs:  
![Screenshot from 2024-05-24 14-12-26](https://github.com/moevm/os_profiling/assets/90711883/f77101b4-9400-4750-95a7-e95534bc27bb)

In the line  
`Sstate summary: Wanted 1867 Local 0 Mirrors 1863 Missed 4 Current 0 (99% match, 0% complete)`  
it shows that 99% of tasks were fetched from the mirror. Here's a chart of resource usage during image build with cache and hash servers enabled:

![image](https://github.com/moevm/os_profiling/assets/90711883/2f69ca45-eaa1-4dee-a150-5db4269a8953)
