# How Layers Are Added

1. To add a layer, you need its repository. Therefore, the first step is cloning the repository.
2. The second step is modifying the file `/poky/build/conf/bblayers.conf` by adding the path to the layer directory (where the repository was cloned) to the `BBLAYERS` variable. This can be done manually, but it’s easier to use the BitBake utility:  
   `bitbake-layers add-layer <path_to_directory>`

After these two steps, the layer will be added, provided it is compatible with the base layer.

## Attempt to Add Layers

1) meta-cgl (meta-cgl-common): depends on filesystems-layer, networking-layer, openembedded-layer, perl-layer, security, selinux:  
   - filesystems-layer: incompatible with base layer, compatible with styhead and scarthgap  
   - networking-layer: incompatible with base layer, compatible with scarthgap and styhead  
   - oe-layer: incompatible with base layer, compatible with scarthgap and styhead  
   - perl-layer: incompatible with base layer, compatible with scarthgap and styhead  
2) meta-clang: added successfully  
3) meta-cloud-services: incompatible with base layer, suggests scarthgap compatibility; depends on meta-virtualization  
4) meta-dpdk: added successfully  
5) meta-erlang: added successfully  
6) meta-java: incompatible with base layer, suggests scarthgap compatibility  
7) meta-openembedded: contains many layers, incompatible with base layer, suggests compatibility with scarthgap and styhead  
8) meta-qt5: incompatible with base layer, suggests scarthgap compatibility  
9) meta-rust: incompatible with base layer, suggests compatibility with kirkstone, honister, mickledore, hardknott, gatesgarth  
10) meta-security: depends on openembedded-layer  
11) meta-selinux: incompatible with base layer, suggests scarthgap compatibility  
12) meta-sysrepo: incompatible with base layer, suggests honister compatibility  
13) meta-virtualization: depends on filesystems-layer, meta-python, networking-layer, openembedded-layer  
14) meta-xilinx: repository contains many layers, unclear which one is needed, all incompatible with base layer; suggests scarthgap compatibility  
15) meta-xilinx-tools: incompatible with base layer, suggests scarthgap compatibility; depends on meta-xilinx and meta-xilinx-standalone

## Attempt to Add Layers After Switching Base Layer to scarthgap

Layer addition order was changed because some layers depend on others:  
Addition order:

1) meta-oe (added first as others depend on it)  
2) meta-python (required by other layers)  
3) meta-networking (required by other layers)  
4) meta-filesystems (required by other layers)  
5) meta-perl (required by other layers)  
6) meta-security (added early due to dependencies)  
7) meta-selinux (added early due to dependencies)  
8) meta-cgl (meta-cgl-common): added (all dependencies already added)  
9) meta-clang: added  
10) meta-virtualization: added (needed by other layers)  
11) meta-cloud-services: added (meta-virtualization already added)  
12) meta-dpdk: added  
13) meta-erlang: added  
14) meta-java: added  
15) meta-qt5: added  
16) meta-xilinx: meta-xilinx-core and meta-xilinx-standalone added (required for meta-xilinx-tools)  
17) meta-xilinx-tools: added  
18) meta-sysrepo: added after editing `layer.conf` (see below)  
19) meta-rust: added after editing `layer.conf` (see below)

## Attempt to Modify Configuration for meta-rust and meta-sysrepo

After analyzing BitBake source code, it was found that some layers are marked incompatible with the base layer due to the `LAYERSERIES_COMPAT_<layername>` variable in the `layer.conf` file. This variable lists compatible base layers.

If the current base layer isn’t listed there, an error is thrown.  
To work around this, the `scarthgap` layer was manually added to the `LAYERSERIES_COMPAT` variable in the `layer.conf` files of meta-rust and meta-sysrepo.

After this change, both layers were added successfully without errors. However, this method could potentially lead to build issues later — further investigation is needed.

### Still Not Added:
1) meta-ypl: not found
