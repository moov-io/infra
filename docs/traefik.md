## traefik

[Traefik](https://docs.traefik.io/) is a "cloud native" load balancer. We choose this project because it has Kubernetes and Let's Encrypt integration. Traefik can watch `Ingress` objects and reload routing rules. Make sure to [understand the Traefik basics](https://docs.traefik.io/basics/) and the Kubernetes [configuration](https://docs.traefik.io/configuration/backends/kubernetes/) and [user guide](https://docs.traefik.io/user-guide/kubernetes/).

### auth proxy

We run the [bitly/oauth2_proxy](https://github.com/bitly/oauth2_proxy) to handle auth infront of our infra resources. You just need to authorize our Github OAuth2 application (oauth creds are in `11-secrets.yml`) to be granted access.
