#!/bin/bash

set -e

## Check cwd is infra/

name=$1
if [[ -z "$name" ]];
then
    echo "Missing customer name"
    exit 1
fi

## Setup customer k8s namespace
## TODO(adam): docs: these are named 'ach-$name'

dir=deployments/ach-"$name"
mkdir "$dir"
cd "$dir"

# Setup terraform files
ln -s ../../modules/terraform/hosted-ach/*

# TODO(adam): configure variables?

# Deploy customer
terraform init
terraform apply
# TODO(adam): kubectl apply
