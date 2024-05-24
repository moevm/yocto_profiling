#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Please provide a password as an argument."
else
    if ! echo "$1" | sudo -S -k true 2>/dev/null; then
        echo "Error: Wrong password."
    else
        sudo -S chown -R $USER:$USER server_folder* <<< "$1"
        echo "Set tmp user as folders owner"
    fi
fi