#! /bin/bash

ip=$(python3 get_ip.py)


# PORT=$1

PORT=8877

echo "Use ip = $ip"

if [ ! -d "./poky" ]; then
	echo "Clone Poky."
	git clone git://git.yoctoproject.org/poky
fi

branch_name=my-upstream_5.0.1
commit_hash=4b07a5316ed4b858863dfdb7cab63859d46d1810

cd ./poky 

source oe-init-build-env 

cd ../..

mkdir hashserver

echo "start hash server at -- $ip:$PORT"

bitbake-hashserv -b $ip:$PORT

sleep infinity

