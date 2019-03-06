## Prometheus Alerts

Prometheus support declaring conditions which, when met trigger "Alerts". These alerts can be used to notify humans in slack, PagerDuty, or even automated processes. Alerts are based off metric data and sliding time windows of observations. Refer to the [Prometheus docs for complete details](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/).

```yaml
# Example alert
groups:
  - name: ./ofac.rules
    rules:
      - alert: StaleOFACData
        expr: (time() - last_ofac_data_refresh_success) > 60*60*24
        for: 1h
        labels:
          severity: warning
        annotations:
          description: "OFAC data was last refreshed {{ humanizeTimestamp $value }} ago"
```

Right now the production alerts are defined in `envs/prod/14-prometheus-rules.yml` with each sub-object written as a file to disk (managed in the Prometheus `Deployment` in volumes).


## Updating Prometheus Alerts

We have automation for updating most of the Prometheus alerts we deploy. This is done with the Go code at [`github.com/moov-io/infra/cmd/kubernetes-mixins`](../cmd/kubernetes-mixins/) following the steps [laid out on kubernetes-monitoring/kubernetes-mixin's documentation](https://github.com/kubernetes-monitoring/kubernetes-mixin#generate-config-files). To update the alets run:

```
$ go fmt ./cmd/kubernetes-mixins/ && make generate
2019/03/05 16:29:20 Installing jsonnet and jsonnet-bundler to your system
```

**Note**: This is currently only supported on macOS and **will install jsonnet and [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler) to your system!
