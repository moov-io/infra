## Hosting Checklist

### Contract

- [ ] SOC2 handoff, accepted
- [ ] SLA's, signed and accepted
- [ ] Hosting Agreement, signed
   - [ ] Backups
      - Credentials needed if external storage system
   - [ ] Failover
      - Credentials needed if external site used

### Support

- [ ] Emails, phone numbers, private slack room?

### Infrastructure

- [ ] DNS endpoint (e.g. api.bank.com)
- [ ] Private code storage of their configuration
- [ ] Isolated virtual environment
   - [ ] Kubernetes (GKE), Hosted MySQL?
- [ ] Debugging and Monitoring
   - [ ] OAuth2 Proxy
   - [ ] infra-idx
   - [ ] Prometheus
   - [ ] Grafana
   - [ ] kube-state-metrics
   - [ ] CAdvisor
   - [ ] node_exporter
   - [ ] Loki
   - [ ] promtail
   - [ ] domain-exporter
   - [ ] alertmanager
   - [ ] polaris?

### Load Balacing

- [ ] Traefik
   - [ ] SSL Certificates (skip if automated)

### Applications

- [ ] api (api.bank.com website and docs)
- [ ] ACH
- [ ] Accounts
- [ ] Auth
- [ ] Customers
- [ ] FED
<!-- - [ ] ImageCashLetter -->
- [ ] PayGate
- [ ] Watchman
<!-- - [ ] Wire -->
