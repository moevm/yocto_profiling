#! /bin/bash

install -o 1001 -g 1001 -d /opt/yocto/docker-yocto-builder

cd /opt/yocto/docker-yocto-builder

source /opt/yocto/poky/oe-init-build-env

bitbake core-image-minimal
