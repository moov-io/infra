## Kubernetes Runbooks

You should be [familiar with Kubernetes](https://kubernetes.io/docs/tutorials/kubernetes-basics/) (k8s). We use lots of `Service`, `Deployment`, `Ingress` and `PersistentVolumeClaim` objects along with a few others where needed. Our clusters run with [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) on Google's Kubernetes Engine (GKE).

**Links**: [infra.moov.io](https://infra.moov.io) | [Google Cloud Status](https://status.cloud.google.com/) | [GKE Dashboard](https://console.cloud.google.com/kubernetes/list)

There are also several gommunity guides for troubleshooting Kubernetes problems:

- [Kubernetes.io Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/)
- [Cloud.gov Guide](https://cloud.gov/docs/ops/runbook/troubleshooting-kubernetes/)
- [Codefresh.io Guide](https://codefresh.io/Kubernetes-Tutorial/recover-broken-kubernetes-cluster/)

### Viewing Pod/Container logs

```
$ kubectl get pods -n infra  | grep kube-ingress
kube-ingress-index-5cb86955ff-md64n   1/1       Running   0          18m
kube-ingress-index-5cb86955ff-xdb5m   1/1       Running   0          18m

# --tail only shows the last N logs
# -f keeps tailing the pod/container stdout
$ kubectl logs -n infra [--tail 10] [-f] kube-ingress-index-5cb86955ff-xdb5m
...
```

### Rolling Pods / Containers

If you need to restart a Pod/Container simply list out the pods and issue `kubectl delete`:

```
$ kubectl get pods -n infra  | grep kube-ingress
kube-ingress-index-5cb86955ff-md64n   1/1       Running   0          18m
kube-ingress-index-5cb86955ff-xdb5m   1/1       Running   0          18m

$ kubectl delete pod -n infra kube-ingress-index-5cb86955ff-rtdms
pod "kube-ingress-index-5cb86955ff-rtdms" deleted
```

### Emacs

[chrisbarrett/kubernetes-el](https://github.com/chrisbarrett/kubernetes-el) works with our setup. Talk to @adamdecaf for help.
