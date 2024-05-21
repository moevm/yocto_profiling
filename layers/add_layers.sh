git checkout -b scarthgap origin/scarthgap

git clone git://git.openembedded.org/meta-openembedded
git clone git://git.yoctoproject.org/meta-security
git clone git://git.yoctoproject.org/meta-selinux
git clone git://git.yoctoproject.org/meta-cgl
git clone https://github.com/kraj/meta-clang
git clone git://git.yoctoproject.org/meta-virtualization
git clone git://git.yoctoproject.org/meta-cloud-services
git clone git://git.yoctoproject.org/meta-dpdk
git clone https://github.com/joaohf/meta-erlang
git clone git://git.yoctoproject.org/meta-java
git clone https://github.com/meta-qt5/meta-qt5
git clone https://github.com/Xilinx/meta-xilinx
git clone https://github.com/Xilinx/meta-xilinx-tools
git clone https://github.com/meta-rust/meta-rust
git clone https://github.com/sartura/meta-sysrepo

source oe-init-build-env
cd ..

bitbake-layers add-layer ./meta-openembedded/meta-oe/
bitbake-layers add-layer ./meta-openembedded/meta-python/
bitbake-layers add-layer ./meta-openembedded/meta-networking/
bitbake-layers add-layer ./meta-openembedded/meta-filesystems/
bitbake-layers add-layer ./meta-openembedded/meta-perl/
bitbake-layers add-layer ./meta-security/
bitbake-layers add-layer ./meta-selinux/
bitbake-layers add-layer ./meta-cgl/meta-cgl-common/
bitbake-layers add-layer ./meta-clang/
bitbake-layers add-layer ./meta-virtualization/
bitbake-layers add-layer ./meta-cloud-services/
bitbake-layers add-layer ./meta-dpdk/
bitbake-layers add-layer ./meta-erlang/
bitbake-layers add-layer ./meta-java/
bitbake-layers add-layer ./meta-qt5/
bitbake-layers add-layer ./meta-xilinx/meta-xilinx-core/
bitbake-layers add-layer ./meta-xilinx/meta-xilinx-standalone/
bitbake-layers add-layer ./meta-xilinx-tools/

original_sysrepo="$(grep LAYERSERIES_COMPAT ./meta-sysrepo/conf/layer.conf | sed 's/.$//')"
original_rust="$(grep LAYERSERIES_COMPAT ./meta-rust/conf/layer.conf | sed 's/.$//')"
new_value=' scarthgap'
sed -i "s/$original_sysrepo/$original_sysrepo$new_value/" ./meta-sysrepo/conf/layer.conf
sed -i "s/$original_rust/$original_rust$new_value/" ./meta-rust/conf/layer.conf


bitbake-layers add-layer ./meta-sysrepo/
bitbake-layers add-layer ./meta-rust/
