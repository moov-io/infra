#!/bin/bash

set -e

# assume this is ran from the root of moov-io/infra

files=(
    envs/prod/apps/10-achfuzz.yml
    envs/prod/apps/17-imagecashletterfuzz.yml
    envs/prod/apps/18-wirefuzz.yml
)

for file in "${files[@]}"
do
    kubectl delete -f "$file"
    kubectl apply -f "$file"
done
