## deployments

This directory contains all of our various deployments. We have a naming pattern for some deployment types:

- `ach-*`: This is a hosted instance of our `ach` service, which contains a Go binary and... TODO(adam)
- `infra`: Our infrastructure services, which include Grafana, Prometheus, ELK/EFK etc.. TODO(adam)
- `k8s`: Configuration for our kubernetes deployment.
- `mysql-ach`: The mysql setup for all of our hosted `ach` deployments.
