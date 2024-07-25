#! /bin/bash

cd $YOCTO_INSTALL_PATH/assembly

for dir in "./logs" "./poky" "./build"
do
	if [ ! -d $dir ]; then
        	echo "Build the project first."
		exit 1

	fi
done

echo "Try to start yocto-project."
./poky/scripts/runqemu ./build/tmp/deploy/images/qemux86-64 slirp nographic

# Shutdown system = `Ctrl + A`, press `X`
# Alternatively = `Ctrl + A`, press `C`, type `quit`
