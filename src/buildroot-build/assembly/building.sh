#! /bin/bash


cd $BUILDROOT_INSTALL_PATH/buildroot

branch=$(git branch --show-current)

if [ "$branch" != "my-buildroot" ];
then
  echo "Switch the branch."
  git checkout -b my-buildroot
fi

make O=$BUILDROOT_INSTALL_PATH/assembly/build raspberrypi3_defconfig


cd $BUILDROOT_INSTALL_PATH/assembly/build

# logs engine -> ./logs

make

