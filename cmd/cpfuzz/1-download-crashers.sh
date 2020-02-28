#!/bin/bash
set -e

dir="fuzz-"$(date +"%Y-%m-%d")
containers=($(kubectl get pods -n apps | grep fuzz | cut -d' ' -f1))
echo "found ${#containers[@]} fuzz containers"

for container in "${containers[@]}"
do
    name=$(echo "$container" | grep -E -o -o '(.*)fuzz' | tr -d ' ' | rev | cut -c5- | rev)
    echo "downloading $name fuzz data from $container"
    mkdir -p "$dir"/"$name"

    files=($(kubectl exec -n apps "$container" -- ls -1 /go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/))
    echo "downloading ${#files[@]} files from $container"
    for file in "${files[@]}"
    do
        kubectl cp apps/"$container":/go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/"$file" "$dir"/"$name" > /dev/null
    done
done

echo "Saved files in $dir"
