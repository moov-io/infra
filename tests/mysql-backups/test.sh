#!/bin/bash
# set -x
set -e

docker-compose kill && docker-compose rm -f -v

apps=($(gsutil ls gs://moov-production-mysql-backups/apps/))

for app in "${apps[@]}"
do
    DB=$(basename "$app") docker-compose up -d mysql
    sleep 20

    line=$(gsutil ls "$app" | tail -n1)
    gsutil cp "$line" $(basename "$line")
    cat $(basename "$line") | mysql -h 127.0.0.1 -u infra --password=password $(basename "$app")

    result=$(cat $(basename "$app")-check.sql | mysql -h 127.0.0.1 -u infra --password=password --silent $(basename "$app"))

    if [ "$result" == "0" ]
    then
        echo "no rows found"
        exit 1
    fi

    result=$(echo 'select count(*) from migrations' | mysql -h 127.0.0.1 -u infra --password=password --silent $(basename "$app"))

    if [ "$result" == "0" ]
    then
        echo "no rows found"
        exit 1
    fi

    docker-compose kill && docker-compose rm -f -v
done
