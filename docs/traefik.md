## traefik

[Traefik](https://docs.traefik.io/) is a "cloud native" load balancer. We chose this project because it has Kubernetes and Let's Encrypt integration. Traefik can watch `Ingress` objects and reload routing rules. Make sure to [understand the Traefik basics](https://docs.traefik.io/basics/) and the Kubernetes [configuration](https://docs.traefik.io/configuration/backends/kubernetes/) and [user guide](https://docs.traefik.io/user-guide/kubernetes/).

Note: We deploy traefik as two deployments, "alpha" and "beta" (along with their `PersistentVolumeClaim`) such that:

1. The traefik `ConfigMap` can be reloaded per-side first (and not accidently drop all traffic)
1. We can help isolate failure.
   - We've been having our preemptible nodes die and taking traefik with. (Issue: [#20](https://github.com/moov-io/infra/issues/20))
   - The PVC has to (maybe) move, re-mount, and then traefik can start...

### Authentication

#### Infra auth proxy

We run the [pusher/oauth2_proxy](https://github.com/pusher/oauth2_proxy) to handle auth infront of our infra-oss.moov.io resources. You just need to authorize our Github OAuth2 application (oauth creds are in `11-secrets.yml`) to be granted access. This [blog post](https://www.digitalocean.com/community/tutorials/how-to-protect-private-kubernetes-services-behind-a-github-login-with-oauth2_proxy) from DigitalOcean covers a similar setup to how we've deployed oauth2_proxy.

### Certificates

We use [Let's Encrypt](https://letsencrypt.org/) integration in Traefik to [dynamically generate certificates](https://docs.traefik.io/configuration/acme/) according to hostnames specified in `Ingress` objects. Each certificate is stored in a `PersistentVolume` and rotated automatically by Traefik. For configuration parameters checkout the `ConfigMap` called `traefik-config` in the `lb` namespace.

Also, we monitor the [Certificate Transparency](https://www.certificate-transparency.org/) logs for `moov.io` (and any future domains) [with CertSpotter](https://sslmate.com/certspotter/).

Read over the [https.dev ACME Operations](https://docs.https.dev/acme-ops#introduction) tips and tricks for in-depth technical knowledge of certificate gathering.
