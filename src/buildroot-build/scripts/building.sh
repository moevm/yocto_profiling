#! /bin/bash

#install -o 1001 -g 1001 -d /opt/buildroot_dir/docker-buildroot-builder

#cd /opt/buildroot_dir/docker-buildroot-builder

cd /opt/buildroot_dir/buildroot

make raspberrypi3_defconfig

make

