function clone_layer() {
    git clone $url
    directory="./$(basename $url)"
    cd $directory
    git checkout $commit_hash -b scarthgap
    cd ..
}


cd ./poky
git checkout -b scarthgap origin/scarthgap

url="https://git.openembedded.org/meta-openembedded"
commit_hash="6de0ab744341ad61b0661aa28d78dc6767ce0786"
clone_layer

url="https://git.yoctoproject.org/meta-security"
commit_hash=11ea91192d43d7c2b0b95a93aa63ca7e73e38034
clone_layer

url="https://git.yoctoproject.org/meta-selinux"
commit_hash=07f3233374f013412d691732adfa2c20167a0ea0
clone_layer

url="https://git.yoctoproject.org/meta-cgl"
commit_hash=f7c4e7165fa32543e0b881d6cd3048458896f535
clone_layer

url="https://github.com/kraj/meta-clang"
commit_hash=e7dceb1c92caf7f21ef1d7b49c85328c30cffd90
clone_layer

url="https://git.yoctoproject.org/meta-virtualization"
commit_hash=1a547c0aa0d75c4143cbb66de6e653d51cdc8bda
clone_layer

url="https://git.yoctoproject.org/meta-cloud-services"
commit_hash=61d37af7f412aa1ecacdf584faf0fba300f7d58e
clone_layer

url="https://git.yoctoproject.org/meta-dpdk"
commit_hash=0f12d2eddf2f7cde8de274ffe225f3c8e912928d
clone_layer

url="https://github.com/joaohf/meta-erlang"
commit_hash=3a83dcadce32910f38100c4ef39d6f298456d3d4
clone_layer

url="https://git.yoctoproject.org/meta-java"
commit_hash=4799a6291223467311d24ed3e1af367aadea122e
clone_layer

url="https://github.com/meta-qt5/meta-qt5"
commit_hash=d8eeef0bfd84672c7919cd346f25f7c9a98ddaea
clone_layer

url="https://github.com/Xilinx/meta-xilinx"
commit_hash=7965de51f877c3dff9f9ca08a2f95cc80b0ed598
clone_layer

url="https://github.com/Xilinx/meta-xilinx-tools"
commit_hash=989ef0bc701665bd2d9f7a8b9e1c18d84aed2393
clone_layer

url="https://github.com/meta-rust/meta-rust"
commit_hash=9611b42d73c7546c3d845da380943a0a4f4205f0
clone_layer

url="https://github.com/sartura/meta-sysrepo"
commit_hash=09f73e78795caaecf15267406d241e501c6e0d62
clone_layer

cd ..
source ./poky/oe-init-build-env build
cd ..


echo "BITBAKE ADD LAYERS: PATH: $(pwd)"
bitbake-layers add-layer ./poky/meta-openembedded/meta-webserver/ ./poky/meta-openembedded/meta-oe/ ./poky/meta-openembedded/meta-python/ ./poky/meta-openembedded/meta-networking/ ./poky/meta-openembedded/meta-filesystems/ ./poky/meta-openembedded/meta-perl/ ./poky/meta-openembedded/meta-multimedia/ ./poky/meta-security/ ./poky/meta-selinux/ ./poky/meta-cgl/meta-cgl-common/ ./poky/meta-clang/ ./poky/meta-virtualization/ ./poky/meta-cloud-services/ ./poky/meta-dpdk/ ./poky/meta-erlang/ ./poky/meta-java/ ./poky/meta-qt5/ ./poky/meta-xilinx/meta-xilinx-core/ ./poky/meta-xilinx/meta-xilinx-standalone/ ./poky/meta-xilinx-tools/


original_sysrepo="$(grep LAYERSERIES_COMPAT ./poky/meta-sysrepo/conf/layer.conf | sed 's/.$//')"
new_value=' scarthgap'
sed -i "s/$original_sysrepo/$original_sysrepo$new_value/" ./poky/meta-sysrepo/conf/layer.conf


bitbake-layers add-layer ./poky/meta-sysrepo/
