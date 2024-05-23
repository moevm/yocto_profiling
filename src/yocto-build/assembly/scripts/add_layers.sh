cd ./poky
git checkout -b scarthgap origin/scarthgap

git clone -b scarthgap git://git.openembedded.org/meta-openembedded
git clone -b scarthgap git://git.yoctoproject.org/meta-security
git clone -b scarthgap git://git.yoctoproject.org/meta-selinux
git clone -b master git://git.yoctoproject.org/meta-cgl
git clone -b scarthgap https://github.com/kraj/meta-clang
git clone -b scarthgap  git://git.yoctoproject.org/meta-virtualization
git clone -b scarthgap git://git.yoctoproject.org/meta-cloud-services
git clone -b scarthgap  git://git.yoctoproject.org/meta-dpdk
git clone -b master https://github.com/joaohf/meta-erlang
git clone -b scarthgap git://git.yoctoproject.org/meta-java
git clone -b scarthgap https://github.com/meta-qt5/meta-qt5
git clone -b scarthgap https://github.com/Xilinx/meta-xilinx
git clone -b scarthgap https://github.com/Xilinx/meta-xilinx-tools
git clone -b master https://github.com/meta-rust/meta-rust
git clone -b master https://github.com/sartura/meta-sysrepo

cd ..
source ./poky/oe-init-build-env build
cd ..



bitbake-layers add-layer ./poky/meta-openembedded/meta-oe/
bitbake-layers add-layer ./poky/meta-openembedded/meta-python/
bitbake-layers add-layer ./poky/meta-openembedded/meta-networking/
bitbake-layers add-layer ./poky/meta-openembedded/meta-filesystems/
bitbake-layers add-layer ./poky/meta-openembedded/meta-perl/
bitbake-layers add-layer ./poky/meta-security/
bitbake-layers add-layer ./poky/meta-selinux/
bitbake-layers add-layer ./poky/meta-cgl/meta-cgl-common/
bitbake-layers add-layer ./poky/meta-clang/
bitbake-layers add-layer ./poky/meta-virtualization/
bitbake-layers add-layer ./poky/meta-cloud-services/
bitbake-layers add-layer ./poky/meta-dpdk/
bitbake-layers add-layer ./poky/meta-erlang/
bitbake-layers add-layer ./poky/meta-java/
bitbake-layers add-layer ./poky/meta-qt5/
bitbake-layers add-layer ./poky/meta-xilinx/meta-xilinx-core/
bitbake-layers add-layer ./poky/meta-xilinx/meta-xilinx-standalone/
bitbake-layers add-layer ./poky/meta-xilinx-tools/

original_sysrepo="$(grep LAYERSERIES_COMPAT ./poky/meta-sysrepo/conf/layer.conf | sed 's/.$//')"
original_rust="$(grep LAYERSERIES_COMPAT ./poky/meta-rust/conf/layer.conf | sed 's/.$//')"
new_value=' scarthgap'
sed -i "s/$original_sysrepo/$original_sysrepo$new_value/" ./poky/meta-sysrepo/conf/layer.conf
sed -i "s/$original_rust/$original_rust$new_value/" ./poky/meta-rust/conf/layer.conf


bitbake-layers add-layer ./poky/meta-sysrepo/
bitbake-layers add-layer ./poky/meta-rust/
