## MySQL

### Viewing Logs

To view logs in [Grafana / Loki](https://infra.moov.io/grafana/explore) you can run a query like the following:

```
{app="paygate-mysql"}
```

Also, if you have a unique ID (example: `e404c20a-e74a-4360-8ed3-7381d76b7b6a`) you can filter results with the following query.

```
{app="paygate"} |= "e404c20a-e74a-4360-8ed3-7381d76b7b6a"
```

Note: We have a more comprehensive guide to [viewing logs](https://github.com/moov-io/infra/blob/master/docs/kubernetes.md#viewing-logs-with-loki--grafana).

### Dashboards

We host several dashboards to monitor MySQL statistics on our Grafana instance.

- [MySQL Overview](https://infra.moov.io/grafana/d/MQWgroiiz/mysql-overview)

### Backups

To view the backups if you have `gsutil` setup and authorized to view Google Storage buckets for Moov you can run the following command.

```
$ gsutil ls -r gs://moov-production-mysql-backups/apps/

gs://moov-production-mysql-backups/apps/customers/:
gs://moov-production-mysql-backups/apps/customers/customers_2020_01_15.sql

gs://moov-production-mysql-backups/apps/paygate/:
gs://moov-production-mysql-backups/apps/paygate/paygate_2020_01_15.sql

gs://moov-production-mysql-backups/apps/watchman/:
gs://moov-production-mysql-backups/apps/watchman/watchman_2020_01_15.sql
```
