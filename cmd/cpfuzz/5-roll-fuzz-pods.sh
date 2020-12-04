#!/bin/bash
set -e

context=$(kubectl config get-contexts --output name | grep automated-clearing-house)

# assume this is ran from the root of moov-io/infra

files=(
    envs/oss/apps/10-achfuzz.yml
    envs/oss/apps/17-imagecashletterfuzz.yml
    envs/oss/apps/18-wirefuzz.yml
    envs/oss/apps/19-metro2fuzz.yml
    envs/oss/apps/20-iso8583fuzz.yml
)

for file in "${files[@]}"
do
    kubectl --context "$context" delete -f "$file"
    kubectl --context "$context" apply -f "$file"
done
