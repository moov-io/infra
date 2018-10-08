#!/bin/bash

FILES=$(find ./images/ -maxdepth 2 -mindepth 2 -type f -name Dockerfile)
for dockerfile in "${FILES[@]}";
do
    cd `dirname "$dockerfile"`
    make docker
    if [ -f "test.sh" ];
    then
        exec ./test.sh
    fi
    cd -
done
