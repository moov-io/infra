#!/bin/bash
set -e

modules=($(find ./modules -type d -maxdepth 1 -mindepth 1))
old=$(pwd)

for module in "${modules[@]}"
do
    cd "$module"
    echo "Checking $module"
    terraform validate
    cd "$old"
done
