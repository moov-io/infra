#!/bin/bash
set -e

modules=($(find ./modules -maxdepth 1 -mindepth 1 -type d))
old=$(pwd)

for module in "${modules[@]}"
do
    cd "$module"
    echo "Checking $module"

    if [ ! -d ".terraform" ]; then
        terraform init
    fi

    terraform validate
    cd "$old"
done
