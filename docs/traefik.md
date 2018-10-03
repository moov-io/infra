## traefik

[Traefik](https://docs.traefik.io/) is a "cloud native" load balancer. We choose this project because it has Kubernetes and Let's Encrypt integration. Traefik can watch `Ingress` objects and reload routing rules. Make sure to [understand the Traefik basics](https://docs.traefik.io/basics/) and the Kubernetes [configuration](https://docs.traefik.io/configuration/backends/kubernetes/) and [user guide](https://docs.traefik.io/user-guide/kubernetes/).

Note: We deploy traefik as two deploymens, "alpha" and "beta" (along with their `PersistentVolumeClaim`) such that:

1. The traefik `ConfigMap` can be reload per-side first (and not accidently drop all traffic)
1. We can help isolate failure.
   - We've been having our pre-emptible nodes die and taking traefik with. (Issue: [#20](https://github.com/moov-io/infra/issues/20))
   - The the PVC has to (maybe) move, re-mount, and then traefik can start...

### auth proxy

We run the [bitly/oauth2_proxy](https://github.com/bitly/oauth2_proxy) to handle auth infront of our infra resources. You just need to authorize our Github OAuth2 application (oauth creds are in `11-secrets.yml`) to be granted access.

### Cross Origin Resource Sharing (CORS)

We enable CORS via preflight checks by parsing out the `Origin` header in requests, ensuring it's a valid URL and responding with the origin and other `Access-Control-Allow-*` headers. The flow looks like this:

```
(browser)
 OPTIONS  ->  traefik -> `auth` (responds with headers) -> browser (traefik forwards CORS headers)
```

The response headers are proxied from `auth` back to the original client accoring to `ingress.kubernetes.io/auth-response-headers` on each `Ingress`. 

[Mozilla MDN docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
