#!/bin/bash
set -e

containers=($(kubectl get pods -n apps | grep auth | grep -v oauth | cut -d' ' -f1))
echo "found ${#containers[@]} auth containers"

for container in "${containers[@]}"
do
    echo "downloading auth.db from $container"
    rm -f auth.db auth.db.old
    kubectl cp -n apps "$container":/opt/moov/auth/auth.db auth.db.old
    # Trick to unlock a sqlite db from https://stackoverflow.com/a/7740613
    echo ".dump" | sqlite3 auth.db.old | sqlite3 auth.db
    rm -f auth.db auth.db.old
    echo 'select distinct email from users;' | sqlite3 auth.db | grep -v 'example.com' | grep -v 'moov.io' | sort
done
