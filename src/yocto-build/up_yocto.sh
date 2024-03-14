#! /bin/bash


./assembly/poky/scripts/runqemu ./assembly/build_yocto/tmp/deploy/images/qemux86-64 slirp nographic

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`
