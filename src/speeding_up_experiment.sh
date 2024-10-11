#!/bin/bash

newgrp docker

if [ -z "$1" ]; then
  echo "Enter number of times to build yocto image"
  exit 1
fi

num_runs=$1

times=()

 for ((i=1; i<=num_runs; i++)); do
  ./entrypoint.sh clean-build
  ./entrypoint.sh clean-docker
  ./entrypoint.sh build_env --no-perf

  ./entrypoint.sh build_yocto_image --only-poky
  ./entrypoint.sh patch add_net_limit.patch add_net_buildstats.patch

  start_time=$(date +%s)
  timeout 300 ./entrypoint.sh build_yocto_image
  end_time=$(date +%s)

  elapsed_time=$((end_time - start_time))
  times+=($elapsed_time)

done

total_time=0
for time in "${times[@]}"; do
  total_time=$((total_time + time))
done

average_time=$((total_time / num_runs))

echo "Average time: $average_time s"