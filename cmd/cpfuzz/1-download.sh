#!/bin/bash
set -e

context=$(kubectl config get-contexts --output name | grep automated-clearing-house)

dir="fuzz-"$(date +"%Y-%m-%d")
containers=($(kubectl --context "$context" get pods -n apps | grep fuzz | cut -d' ' -f1))
echo "found ${#containers[@]} fuzz containers"

subdir=""
if [[ "$1" != "" ]];
then
    subdir="$1"
else
    subdir="crashers"
fi

for container in "${containers[@]}"
do
    name=$(echo "$container" | grep -E -o -o '(.*)fuzz' | tr -d ' ' | rev | cut -c5- | rev)
    echo "downloading $name fuzz data from $container"
    mkdir -p "$dir"/"$name"/"$subdir"

    files=($(kubectl --context "$context" exec -n apps "$container" -- ls -1 /go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/))
    echo "downloading ${#files[@]} files from $container"
    for file in "${files[@]}"
    do
        kubectl --context "$context" cp apps/"$container":/go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/"$file" "$dir"/"$name"/"$subdir"/"$file"
    done
done

echo "Saved files in $dir"
