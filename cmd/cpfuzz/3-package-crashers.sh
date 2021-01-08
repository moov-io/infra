#!/bin/bash
set -e

# assume this is ran from the root of moov-io/infra

last=$(ls -1 | grep fuzz | tail -n1)
if [ -n "$last" ];
then
    echo "Using fuzz findings from $last"
    for dir in $(ls -1 "$last");
    do
        # Create a .tar file of the crashing inputs and outputs
        tar cf "$last"/"$dir".tar "$last"/"$dir"/crashers/*
    done
else
    echo "No fuzz-* directories found in moov-io/infra"
fi
