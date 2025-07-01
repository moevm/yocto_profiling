#! /bin/bash

CONF_FILE=./conf/local.conf
LINE='SANITY_TESTED_DISTROS=""'

cp ./selftest/sstatemirrors.py $POKY_DIR/meta/lib/oeqa/selftest/cases/sstatemirrors.py

source "$POKY_DIR/oe-init-build-env"
if grep -q "^SANITY_TESTED_DISTROS" "$CONF_FILE"; then
    sed -i "s|^SANITY_TESTED_DISTROS.*|$LINE|" "$CONF_FILE"
else
    echo "$LINE" >> "$CONF_FILE"
fi

# oe-selftest requires git configuration
git config --global user.name "Tester User"
git config --global user.email "user@test.com"

cd $POKY_DIR
oe-selftest -r sstatemirrors
