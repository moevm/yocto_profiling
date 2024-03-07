#! /bin/bash


$YOCTO_INSTALL_PATH/poky/scripts/runqemu $YOCTO_INSTALL_PATH/assembly/build/tmp/deploy/images/qemux86-64 slirp nographic

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`
