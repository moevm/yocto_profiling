#! /bin/bash

# INPUT
if (( $# < 3 )); then
        echo "Unexpected parameters count! Expected: POKY_DIR, PATCHES_DIR, list of patches ... and optional --reverse and --patches-list params."
        exit 0
fi

POKY_DIR=$1
PATCHES_DIR=$2
shift 2

echo -e "RUN: python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR --patch $@\n"
python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR --patch $@

