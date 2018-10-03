## traefik

[Traefik](https://docs.traefik.io/) is a "cloud native" load balancer. We choose this project because it has Kubernetes and Let's Encrypt integration. Traefik can watch `Ingress` objects and reload routing rules. Make sure to [understand the Traefik basics](https://docs.traefik.io/basics/) and the Kubernetes [configuration](https://docs.traefik.io/configuration/backends/kubernetes/) and [user guide](https://docs.traefik.io/user-guide/kubernetes/).

Note: We deploy traefik as two deploymens, "alpha" and "beta" (along with their `PersistentVolumeClaim`) such that:

1. The traefik `ConfigMap` can be reload per-side first (and not accidently drop all traffic)
1. We can help isolate failure.
   - We've been having our pre-emptible nodes die and taking traefik with. (Issue: [#20](https://github.com/moov-io/infra/issues/20))
   - The the PVC has to (maybe) move, re-mount, and then traefik can start...

### auth proxy

We run the [bitly/oauth2_proxy](https://github.com/bitly/oauth2_proxy) to handle auth infront of our infra resources. You just need to authorize our Github OAuth2 application (oauth creds are in `11-secrets.yml`) to be granted access.
