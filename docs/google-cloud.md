## Google Cloud setup

We currently deploy moov.io services on [Google Cloud Kubernetes Engine](https://console.cloud.google.com/apis/credentials/serviceaccountkey?project=automated-clearing-house) (GKE) which allows us to deploy on Kubernetes.

**Links**: [GKE Dashboard](https://console.cloud.google.com/kubernetes/list) | [Google Cloud Status](https://status.cloud.google.com/)

### Credentials

1. Download your [Google Cloud credentials file](https://console.cloud.google.com/apis/credentials/serviceaccountkey) (JSON format)
1. Save this file in `~/.google/credentials.json` according to [Terraform's Google Cloud guide](https://www.terraform.io/docs/providers/google/index.html#configuration-reference)
  1. Prevent other users reading this file: `chmod 400 ~/.google/credentials.json`
1. [Optional] Install gcloud cli
   - Quick start: [Linux](https://cloud.google.com/sdk/docs/quickstart-linux) | [macOS](https://cloud.google.com/sdk/docs/quickstart-macos)
   - Requires Python 2.7
   - Install the *kubectl module* `gcloud components install kubectl`
     - Note: You should update the gcloud tools: `gcloud components update`
   - Login `gcloud auth login`
   - Set the default project `gcloud config set project automated-clearing-house`
1. Download your [`kubectl` config](https://console.cloud.google.com/kubernetes/list)
   - Run `gcloud container clusters get-credentials sbx --zone us-central1-a`
   - You can also have terraform setup the credentials for you.
     - You also need the following files `.google/credentials.json`, `envs/sbx/ca.crt`, and `envs/sbx/client.*`, which you can get from Adam.
   - Then `terraform taint null_resource.kubectl_setup` and `terraform apply` (verifying only that resource changes)

### Troubleshooting

#### "cannot construct google default token source"

Sometimes after a homebrew update `kubectl` breaks with the following error:

```
$ kubectl get pods -n infra | grep alertm
error: cannot construct google default token source: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
```

**Solution**

1. Update the gcloud components `gcloud components update`
1. Login `gcloud auth login`
1. Set the project (i.e. `gcloud config set project automated-clearing-house`)
1. Fetch the credentials again (i.e. `gcloud container clusters get-credentials sbx --zone us-central1-a`)
