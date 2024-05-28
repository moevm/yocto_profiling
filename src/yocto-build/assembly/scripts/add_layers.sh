cd ./poky
git checkout -b scarthgap origin/scarthgap

git clone git://git.openembedded.org/meta-openembedded
cd ./meta-openembedded
git checkout 6de0ab744341ad61b0661aa28d78dc6767ce0786 -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-security
cd ./meta-security
git checkout 11ea91192d43d7c2b0b95a93aa63ca7e73e38034 -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-selinux
cd ./meta-selinux
git checkout 07f3233374f013412d691732adfa2c20167a0ea0 -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-cgl
cd ./meta-cgl
git checkout f7c4e7165fa32543e0b881d6cd3048458896f535 -b scarthgap
cd ..

git clone https://github.com/kraj/meta-clang
cd ./meta-clang 
git checkout e7dceb1c92caf7f21ef1d7b49c85328c30cffd90 -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-virtualization
cd ./meta-virtualization
git checkout 1a547c0aa0d75c4143cbb66de6e653d51cdc8bda -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-cloud-services
cd ./meta-cloud-services
git checkout 61d37af7f412aa1ecacdf584faf0fba300f7d58e -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-dpdk
cd ./meta-dpdk
git checkout 0f12d2eddf2f7cde8de274ffe225f3c8e912928d -b scarthgap
cd ..

git clone https://github.com/joaohf/meta-erlang
cd ./meta-erlang
git checkout 3a83dcadce32910f38100c4ef39d6f298456d3d4 -b scarthgap
cd ..

git clone git://git.yoctoproject.org/meta-java
cd ./meta-java
git checkout 4799a6291223467311d24ed3e1af367aadea122e -b scarthgap
cd ..

git clone https://github.com/meta-qt5/meta-qt5
cd ./meta-qt5
git checkout d8eeef0bfd84672c7919cd346f25f7c9a98ddaea -b scarthgap
cd ..

git clone https://github.com/Xilinx/meta-xilinx
cd ./meta-xilinx
git checkout 7965de51f877c3dff9f9ca08a2f95cc80b0ed598 -b scarthgap
cd ..

git clone https://github.com/Xilinx/meta-xilinx-tools
cd ./meta-xilinx-tools
git checkout 989ef0bc701665bd2d9f7a8b9e1c18d84aed2393 -b scarthgap
cd ..

git clone https://github.com/meta-rust/meta-rust
cd ./meta-rust
git checkout 9611b42d73c7546c3d845da380943a0a4f4205f0 -b scarthgap
cd ..

git clone https://github.com/sartura/meta-sysrepo
cd ./meta-sysrepo
git checkout 09f73e78795caaecf15267406d241e501c6e0d62 -b scarthgap
cd ..
pwd

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
