#!/bin/bash
set -e

# assume this is ran from the root of moov-io/infra

last=$(ls -1 | grep fuzz | tail -n1)
if [ -n "$last" ];
then
    echo "Using fuzz findings from $last"
    for dir in $(ls -1 "$last");
    do
        # Copy input files over to wire project
        find "$last"/"$dir" -not -name '*.output' -not -name '*.quoted' -mindepth 1 | xargs -n1 -I '{}' cp {} ../"$dir"/test/testdata/crashers/
    done
else
    echo "No fuzz-* directories found in moov-io/infra"
fi
