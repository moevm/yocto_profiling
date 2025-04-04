#! /bin/bash

PORT=8888

branch_name=my-upstream_5.0.1
commit_hash=59db27de565fb33f9e4326e76ebd6fa3935557b9

cd poky

current_branch=$(git branch --show-current)
if [ "$current_branch" != "$branch_name" ]; then
	echo "Switch the branch."
	git checkout $commit_hash -b $branch_name
fi

. oe-init-build-env build
# source oe-init-build-env

cd ../..

mkdir hashserver

cd hashserver
echo "$PWD"
echo "Start hash server at -- $ip:$PORT"

bitbake-hashserv -b :$PORT

echo "Something wrong with your bitbake-hashserv"

exit 1
