#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage : $0 <start_value> <quantity>"
    exit 1
fi

start_value=$1
quantity=$2

echo "$start_value $quantity" >> servers_params.txt

tmp_ip=$(python3 get_ip.py)

for ((i=start_value; i<start_value+quantity; i++)); do
    # mkdir server_folder_$i
    ./run.sh $i 
    echo "Starting server $tmp_ip:$i"
done
