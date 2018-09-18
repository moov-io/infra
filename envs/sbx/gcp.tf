// Configure the Google Cloud provider
provider "google" {
  credentials = "${file(var.gcp_creds_filepath)}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

variable "gcp_creds_filepath" {
  default     = "~/.google/credentials.json"
  description = "Local filepath for Google Cloud credentials"
}

variable "gcp_project" {
  default     = "automated-clearing-house"
  description = "Google Cloud project name"
}

variable "gcp_region" {
  default = "us-central1"
}

variable "gcp_zones" {
  type = "list"

  default = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
  ]
}

resource "random_shuffle" "zones" {
  input = ["${var.gcp_zones}"]
}

// ClusterRole on GKE/K8S 1.6+ (with RBAC) won't let you create roles right away.
// See the following links:
//
// https://github.com/terraform-providers/terraform-provider-kubernetes/pull/1#issuecomment-307940033
// https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
//
// https://cloud.google.com/container-engine/docs/role-based-access-control
// https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md
//
// To work around this, let's just shell out and create the CRB's ourself.
resource "null_resource" "rbac_setup" {
  count = "${length(var.cluster_admins)}"

  # kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=myname@example.org
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding ${var.cluster_name}-admin-binding --clusterrole=cluster-admin --user=${element(var.cluster_admins, count.index)}"
  }
}

variable "cluster_admins" {
  default = [
    "adam@moov.io",
  ]

  # "wade@moov.io"
}
