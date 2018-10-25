## Google Cloud setup

We currently deploy moov.io services on [Google Cloud Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/) (GKE) which allows us to deploy on Kubernetes.

Links: [GKE Dashboard](https://console.cloud.google.com/kubernetes/list)

### Credentials

1. Download your [Google Cloud credentials file](https://console.cloud.google.com/apis/credentials/serviceaccountkey) (JSON format)
1. Save this file in `~/.google/credentials.json` according to [Terraform's Google Cloud guide](https://www.terraform.io/docs/providers/google/index.html#configuration-reference)
  1. Prevent other users reading this file: `chmod 400 ~/.google/credentials.json`
1. [Optional] Install gcloud cli
   - Quick start: [Linux](https://cloud.google.com/sdk/docs/quickstart-linux) | [macOS](https://cloud.google.com/sdk/docs/quickstart-macos)
   - Requires Python 2.7
   - Install the *kubectl module* `gcloud components install kubectl`
   - Login `gcloud auth login`
   - Set the default project `gcloud config set project sbx`
1. Download your [`kubectl` config](https://console.cloud.google.com/kubernetes/list)
   - Click "Connect" -> "Command-line access"
   - You can also have terraform setup the credentials for you.
     - First, you need `.google/credentials.json`, `envs/sbx/ca.crt`, and `envs/sbx/client.*` setup.
   - Then `terraform taint null_resource.kubectl_setup` and `terraform apply` (verifying only that resource changes)
