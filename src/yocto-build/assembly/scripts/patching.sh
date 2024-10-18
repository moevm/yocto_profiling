#! /bin/bash

# INPUT
if (( $# == 0 )); then
        echo "Unexpected parameters count! Expected patches list."
        exit 0
fi

echo -e "--poky-path $POKY_DIR --dir-path $PATCHES_DIR --patch $@\n"
python3 $PATCHES_DIR/main.py --poky-path $POKY_DIR --dir-path $PATCHES_DIR --patch $@

