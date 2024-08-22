#! /bin/bash

# INPUT
if [ $# -ne 3 ]; then
        echo "Unexpected parameters count! Expected: POKY_DIR, PATCHES_DIR and list of patches <patch1>::<patch2>..."
        exit 0
fi

POKY_DIR=$1
PATCHES_DIR=$2
PATCHES_LIST=$3

echo "RUN: python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR -l $PATCHES_LIST"
python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR -l $PATCHES_LIST

