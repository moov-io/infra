#!/bin/bash

# TODO(adam): quick script to port-forward given a pattern (e.g. 'auth') and collect a pprof profile
#  $ ./cmd/ff/pprof.sh auth

pattern=$1
if [[ -z "$pattern" ]]; then
    echo "ERROR: No pattern specified!"
    exit 1
fi

containers=($(kubectl get pods -n apps | grep "$pattern" | cut -d' ' -f1))
if [ ${#containers[@]} -eq 0 ]; then
    echo "ERROR: no containers found"
    exit 1
else
    echo "found ${containers[0]} container"
fi

# Connect to remote Pod
kubectl port-forward -n apps "${containers[0]}" 9090 &

sleep 5

go tool pprof -web -seconds 10 http://localhost:9090/debug/pprof/profile

# go tool pprof -top http://localhost:6060/debug/pprof/heap
# go tool pprof -http localhost:10001 -seconds 30 http://localhost:9090/debug/pprof/profile

# Kill all background jobs we started
for x in $(jobs -p); do
    kill $x;
done
