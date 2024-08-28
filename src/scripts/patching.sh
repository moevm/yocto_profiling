#! /bin/bash

# INPUT
if ! (( $# >= 3 && $# <= 4 )); then
        echo "Unexpected parameters count! Expected: POKY_DIR, PATCHES_DIR, list of patches <patch1>::<patch2>... and optional REVERSE arg."
        exit 0
fi

POKY_DIR=$1
PATCHES_DIR=$2
PATCHES_LIST=$3
REVERSE=$4

echo "RUN: python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR -l $PATCHES_LIST $REVERSE"
python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR -l $PATCHES_LIST $REVERSE

