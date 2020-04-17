#!/bin/bash

set -e

# assume this is ran from the root of moov-io/infra

files=(
    envs/oss/apps/10-achfuzz.yml
    envs/oss/apps/17-imagecashletterfuzz.yml
    envs/oss/apps/18-wirefuzz.yml
)

for file in "${files[@]}"
do
    kubectl delete -f "$file"
    kubectl apply -f "$file"
done
