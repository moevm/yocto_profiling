#! /bin/bash

cd $1

a_grep=git://git.yoctoproject.org/linux-yocto.git
a_place=";name=machine;branch=\${KBRANCH};protocol=https"
b_grep=git://git.yoctoproject.org/yocto-kernel-cache
b_place=";type=kmeta;name=meta;branch=yocto-6.6;destsuffix=\${KMETA};protocol=https"
add="file://fragment.cfg"

check=$(grep "$add" linux-yocto_6.6.bb)
if [[ -z "$check" ]]; then
	grep -vwE "($a_grep|$b_grep)" linux-yocto_6.6.bb > temp.txt
	cp temp.txt linux-yocto_6.6.bb
	rm -f temp.txt
	echo -e "SRC_URI = \"$a_grep$a_place \\ \n\t$b_grep$b_place \\ \n\t$add\"" >> linux-yocto_6.6.bb
fi

cd - > /dev/null
