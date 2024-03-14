#! /bin/bash


cd $YOCTO_INSTALL_PATH/assembly

if [ ! -d "./poky" ];
then
  git clone git://git.yoctoproject.org/poky
fi


cd $YOCTO_INSTALL_PATH/assembly/poky 
branch=$(git branch --show-current)

if [ "$branch" != "my-nanbield" ];
then
  echo "Switch the branch."
  git checkout -t origin/nanbield -b my-nanbield
fi


cd $YOCTO_INSTALL_PATH/assembly
source $YOCTO_INSTALL_PATH/assembly/poky/oe-init-build-env

# logs engine -> ./logs 

bitbake core-image-minimal
