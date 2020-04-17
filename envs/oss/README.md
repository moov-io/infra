## envs/oss

`oss` is our only environment currently. It's organized with terraform to setup a Kubernetes cluster and then `kubectl` object files laid out in the directories (by each namespace).

- `gcp.tf`: Our Google Cloud project setup. Contains enabled APIs, cluster admins, and zone setup.
- `kubernetes.tf`: Kubernetes cluster setup
   - Contains node counts, memory, cpu, storage, and kubernetes version
- `moov.io.tf`: DNS records for `moov.io` and `*.moov.io`.
- `terraform.tf`: Terraform (Google Cloud Storage) GCS backend config (for [Terraform remote state](https://www.terraform.io/docs/state/remote.html))

Terraform state is stored in a Google Storage Bucket, which gives us:

1. State Locking (so only one `terraform apply` at a time, only allow newer versions)
1. Encryption of terraform state (and keeping secrets out of this git repo)

Make sure your [Google Cloud credentials.json is setup](../../docs/google-cloud.md)

### Decrypting secrets

You'll need to [decrypt the files with blackbox](../../docs/secrets.md). Run `blackbox_decrypt_all_files` at the root of this repository.

Note: The `oss` environment is a testing ground. Never put production secrets into this repository.

### Kubernetes Namespaces

- `apps/`: Kubernetes Service, Deployment, and Ingress for each application
- `infra/`: `infra.moov.io` setup, contains Grafana, prometheus, and oauth2_proxy (for infra resources)
- `lb/`: Load Balancer (Traefik) setup and configuration

### infra.moov.io

[`infra.moov.io`](https://infra.moov.io/) is our VPN-less portal for Grafana, Prometheus and other infra services. It requires being part of the [`moov-io` Github organization](https://github.com/moov-io) and uses OAuth2 auth via Github.

The index page is generated with [Banno/kube-ingress-index](https://github.com/Banno/kube-ingress-index), which scans Ingress objects and generates a dynamic table of contents.

Note: The traefik link currently doesn't work, use the [infra README's link](https://github.com/moov-io/infra#moovio-infra).
