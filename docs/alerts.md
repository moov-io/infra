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
