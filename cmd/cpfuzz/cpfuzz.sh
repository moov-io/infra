#!/bin/bash
set -e

dir="fuzz-"$(date +"%Y-%m-%d")
containers=($(kubectl get pods -n apps | grep fuzz | cut -d' ' -f1))

for container in "${containers[@]}"
do
    name=$(echo "$container" | grep -E -o -o '(.*)fuzz' | tr -d ' ' | rev | cut -c5- | rev)
    echo "downloading $name fuzz data from $container"
    mkdir -p "$dir"/"$name"

    files=($(kubectl exec -n apps "$container" -- ls -1 /go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/ | grep -v 'lost+found'))
    for file in "${files[@]}"
    do
        kubectl cp apps/"$container":/go/src/github.com/moov-io/"$name"/test/fuzz-reader/crashers/"$file" "$dir"/"$name"
    done
done

echo "Saves files in $dir"
