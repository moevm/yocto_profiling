#!/bin/bash

max_servers=50
step=1



if [ -d "configs" ]; then
    rm -rf configs
fi

if [ -d "times" ]; then
    rm -rf times
fi

mkdir times
python3 ./auto_compose_local_conf.py



if [ -d "poky" ]; then
  echo "poky already exist. Removing..."
  rm -rf ./poky
fi

git clone https://github.com/yoctoproject/poky.git && \
    cd poky && \
    branch_name=my-upstream_5.0.1 && \
    commit_hash=59db27de565fb33f9e4326e76ebd6fa3935557b9 && \
    git checkout $commit_hash -b $branch_name
    cd .. 

cp -f async_filter_with_time.patch ./poky/
cd poky 
git apply async_filter_with_time.patch


# В патче изменяются два файл - один замеряет время, а второй реализует функционал. Чтобы измерить исходную ситуацию - используем строку ниже 
git restore bitbake/lib/bb/cookerdata.py


for (( i=2; i<$max_servers; i+=$step ))
do
    source oe-init-build-env
    # copy config
    cp -f ../../configs/${i}/local.conf ./conf

    start=`date +%s`
    bitbake core-image-minimal >> ../../times/$i
    # bitbake core-image-minimal

    end=`date +%s`
    runtime=$((end-start))
    echo -e "[CACHE SERVERS $i]" >> ../../times/times
    echo -e "|$runtime|" >> ../../times/times
    cd .. && rm -rf build

done

echo "reset params!"

git restore meta/classes-global/sstate.bbclass
cd ..
cp -f async_filter_with_time.patch ./poky/
cd poky 
git apply async_filter_with_time.patch



for (( i=2; i<$max_servers; i+=$step ))
do
    source oe-init-build-env
    # copy config
    cp -f ../../configs/${i}/local.conf ./conf

    start=`date +%s`
    bitbake core-image-minimal >> ../../times/Patch_$i
    # bitbake core-image-minimal

    end=`date +%s`
    runtime=$((end-start))
    echo -e "[CACHE SERVERS $i]" >> ../../times/times
    echo -e "|$runtime|" >> ../../times/times
    cd .. && rm -rf build

done










# ### Если нужно применить патч ###
# cp -f async_filter_with_time.patch ./poky/
# cd poky 
# git apply async_filter_with_time.patch
# cd -