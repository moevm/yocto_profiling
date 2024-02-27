#! /bin/bash


cd /home/yocto_user/project/poky

branch=$(git branch --show-current)

if [ "$branch" != "my-nanbield" ];
then
  echo "Switch the branch."
  git checkout -t origin/nanbield -b my-nanbield
fi

cd /home/yocto_user/project/assembly
source /home/yocto_user/project/poky/oe-init-build-env

# logs engine -> ./logs 

bitbake core-image-minimal
