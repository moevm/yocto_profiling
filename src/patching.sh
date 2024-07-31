#! /bin/bash

SOURCE_DIR=$(dirname $0)
POKY_DIR=$SOURCE_DIR/poky
PATCHES_PATH=$SOURCE_DIR/yocto_patches

# PARSE $PATCHES_PATH/patches.cfg
# GET LIST OF AVAILABLE PATCHES FROM patches.cfg
# config type: json
#
# {
# 	"patch_name": {
# 		"path": "path_to_dir",
# 		"file": "file_to_patch"
# 	},
# 	...
# }


# INPUT
# GET PATCHES LIST FROM USER

# VALIDATE
# CHECK IF EXISTS AND AVAILABLE

# BUILD
# MOVE PATCH TO HIS PATH LIKE .../poky/bitbake/lib/bb/
# APPLY PATCH: patch -p1 file < file.patch

