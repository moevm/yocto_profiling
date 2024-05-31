#!/bin/bash

read -s -p "Enter your password: " password
echo

if [ -z "$password" ]; then
    echo "Error: Please provide a password."
else
    if ! echo "$password" | sudo -S -k true 2>/dev/null; then
        echo "Error: Wrong password."
    else
        sudo -S chown -R $USER:$USER server_folder* <<< "$password"
        echo "Set tmp user as folders owner"
    fi
fi
