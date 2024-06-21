#! /bin/bash

PORT=$1
ip=$2


if [ ! -d "./poky" ]; then
	echo "Clone Poky."
	git clone git://git.yoctoproject.org/poky
fi

branch_name=my-upstream_5.0.1
commit_hash=4b07a5316ed4b858863dfdb7cab63859d46d1810

cd ./poky

. oe-init-build-env build
# source oe-init-build-env

cd ../..

mkdir hashserver

cd hashserver
echo "$PWD"
echo "start hash server at -- $ip:$PORT"

bitbake-hashserv -b $ip:$PORT

echo "LL smth wrong"

sleep infinity

