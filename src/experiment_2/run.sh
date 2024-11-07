#!/bin/bash

max_servers=50
step=1



if [ -d "configs" ]; then
    rm -rf configs
fi

if [ -d "times" ]; then
    rm -rf
fi

mkdir times
python3 ./auto_compose_local_conf.py



if [ -d "poky" ]; then
  echo "poky already exist"
else
    git clone git://git.yoctoproject.org/poky && \
        cd poky && \
        branch_name=my-upstream_5.0.1 && \
        commit_hash=4b07a5316ed4b858863dfdb7cab63859d46d1810 && \
        git checkout $commit_hash -b $branch_name 
fi


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
    exit(0)
    # cd .. && rm -rf build






	# # подъём серверов
 	# ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./start_hash.sh $hash_port"  2> /dev/null
	# echo -e "\n\nHash server started at $hash_ip:$hash_port"

	


	# # ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh start $cache_start_port $i" > /dev/null
	# # делаем распределение кэша только на 2 сервера
	# if [ $i -eq 2 ]; then
	# 	# scp -rf ../../../src/ $cache_usr@$cache_ip:$CACHE_SERVER_WORKDIR
	# 	# scp -r ../../../src/ user@10.138.70.7:/home/user/Desktop/test/
	# 	echo "AAAAAAAAAAAAAAAAAAAAAAAA"
	# 	ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh start $cache_start_port $i" > /dev/null
	# 	echo "BBBBBBBBBBBBBBBBBBBBBBBB"

	# fi
	# cd $SCRIPT_DIR/auto_conf && python3 set_num_ports.py --cache_num_port $i
	# echo -e "Building Yocto on host with $i servers: START.\n"

    # cp -f $BASE_DIR/build/conf/experiment.conf $SCRIPT_DIR/auto_conf/conf/local.conf
    # cd $SCRIPT_DIR/auto_conf && python3 auto_compose_local_conf.py
	# echo -e "[CACHE SERVERS $i]" >> $EXPERIMENT_DIR/"times"
	# for j in 1 2
	# do
	# 	cp -f $SCRIPT_DIR/auto_conf/conf/local.conf $BASE_DIR/build/conf/local.conf
	# 	filename="test_${i}_${j}"
	# 	start=`date +%s`
	# 	cd $SRC_DIR && ./entrypoint.sh build_yocto_image --no-layers > $EXPERIMENT_DIR/"$filename"
	# 	end=`date +%s`

	# 	runtime=$((end-start))
	# 	echo -e "REPEAT $j TIME: $runtime" >> $EXPERIMENT_DIR/"times"
	# 	cat $EXPERIMENT_DIR/"$filename" | grep "Parsing recipes: 100% || Time:" >> $EXPERIMENT_DIR/"times"
	# 	cat $EXPERIMENT_DIR/"$filename" | grep "Checking sstate mirror object availability: 100% || Time:" >> $EXPERIMENT_DIR/"times"

	# 	echo -e "Remove build folder\n"
	# 	cd $SRC_DIR/yocto-build/assembly && rm -rf ./build

	# 	sleep 15
	# done
	# echo -e "" >> $EXPERIMENT_DIR/"times"
	# echo -e "Building Yocto on host: DONE.\n"
	# ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh stop" 2> /dev/null
	# ssh $hash_usr@$hash_ip "cd $hash_desktop_path/test/hash_server_setuper && ./manipulate_hash.sh rm" 2> /dev/null
	# # не убиваем контейнер
	# # ssh $cache_usr@$cache_ip "cd $CACHE_SERVER_WORKDIR && ./experiment/cache_containers.sh kill" 2> /dev/null
	
	# sleep 25
done










# ### Если нужно применить патч ###
# cp -f async_filter_with_time.patch ./poky/
# cd poky 
# git apply async_filter_with_time.patch
# cd -