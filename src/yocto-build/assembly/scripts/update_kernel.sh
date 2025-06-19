#! /bin/bash

echo "Do no update kernel link for download"
exit 0

KVER="6.12"

cd $1

a_grep=git://git.yoctoproject.org/linux-yocto.git
a_place=";name=machine;branch=\${KBRANCH};protocol=https"
b_grep=git://git.yoctoproject.org/yocto-kernel-cache
b_place=";type=kmeta;name=meta;branch=yocto-$KVER;destsuffix=\${KMETA};protocol=https"
add="file://fragment.cfg"

check=$(grep "$add" linux-yocto_$KVER.bb)
if [[ -z "$check" ]]; then
	grep -vwE "($a_grep|$b_grep)" linux-yocto_$KVER.bb > temp.txt
	cp temp.txt linux-yocto_$KVER.bb
	rm -f temp.txt
	echo -e "SRC_URI = \"$a_grep$a_place \\ \n\t$b_grep$b_place \\ \n\t$add\"" >> linux-yocto_$KVER.bb
fi

cd - > /dev/null
