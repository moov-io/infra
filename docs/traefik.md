## traefik

[Traefik](https://docs.traefik.io/) is a "cloud native" load balancer. We choose this project because it has Kubernetes and Let's Encrypt integration. Traefik can watch `Ingress` objects and reload routing rules. Make sure to [understand the Traefik basics](https://docs.traefik.io/basics/) and the Kubernetes [configuration](https://docs.traefik.io/configuration/backends/kubernetes/) and [user guide](https://docs.traefik.io/user-guide/kubernetes/).

Note: We deploy traefik as two deploymens, "alpha" and "beta" (along with their `PersistentVolumeClaim`) such that:

1. The traefik `ConfigMap` can be reload per-side first (and not accidently drop all traffic)
1. We can help isolate failure.
   - We've been having our pre-emptible nodes die and taking traefik with. (Issue: [#20](https://github.com/moov-io/infra/issues/20))
   - The the PVC has to (maybe) move, re-mount, and then traefik can start...

### Authentication

#### Infra auth proxy

We run the [pusher/oauth2_proxy](https://github.com/pusher/oauth2_proxy) to handle auth infront of our infra resources. You just need to authorize our Github OAuth2 application (oauth creds are in `11-secrets.yml`) to be granted access.

#### API authentication

An HTTP call like `GET /v1/depositories/:id` with a cookie or OAuth token will hit our LB (traefik)  at `api.moov.io` and a "forward auth" call gets made from traefik to our auth service. The cookie or OAuth token is checked, and if valid '200 OK' is returned to traefik. Only on that '200 OK' is the actual request proxied to paygate (or in this case ofac).

The `Ingress` annotations to setup this forward-auth looks something like this:

```yaml
ingress.kubernetes.io/auth-type: forward
ingress.kubernetes.io/auth-url: https://api.moov.io/v1/auth/check
ingress.kubernetes.io/auth-response-headers: X-Request-Id,X-User-Id,Access-Control-Allow-Origin,Access-Control-Allow-Methods,Access-Control-Allow-Headers,Access-Control-Allow-Credentials,Content-Type
```

Then, with an `Ingress` setup to route to an app traefik first verifies the forward-auth call returns `200 OK` and if so routes accordingly to the `Ingress` object.

```yaml
spec:
  rules:
    - host: api.moov.io
      http:
        paths:
          - path: /v1/ach/receivers
            backend:
              serviceName: paygate
              servicePort: 8080
```

### Cross Origin Resource Sharing (CORS)

We enable CORS via preflight checks by parsing out the `Origin` header in requests, ensuring it's a valid URL and responding with the origin and other `Access-Control-Allow-*` headers. The flow looks like this:

```
(browser)
 OPTIONS  ->  traefik -> `auth` (responds with headers) -> browser (traefik forwards CORS headers)
```

The response headers are proxied from `auth` back to the original client accoring to `ingress.kubernetes.io/auth-response-headers` on each `Ingress`.

[Mozilla MDN docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

### Certificates

We use [Let's Encrypt](https://letsencrypt.org/) integration in Traefik to [dynamically generate certificates](https://docs.traefik.io/configuration/acme/) accoridng to hostnames specified in `Ingress` objects. Each certificate is stored in a `PersistentVolume` and rotated automatically by Traefik. For configuration parameters checkout the `ConfigMap` called `traefik-config` in the `lb` namespace.

Also, we montior the [Certificate Transparency](https://www.certificate-transparency.org/) logs for `moov.io` (and any future domains) [with CertSpotter](https://sslmate.com/certspotter/).
