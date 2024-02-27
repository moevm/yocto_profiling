#! /bin/bash


cd /home/buildroot_user/project/buildroot

branch=$(git branch --show-current)

if [ "$branch" != "my-buildroot" ];
then
  echo "Switch the branch."
  git checkout -b my-buildroot
fi

make O=/home/buildroot_user/project/assembly/build raspberrypi3_defconfig


cd /home/buildroot_user/project/assembly/build

# logs engine -> ./logs

make

