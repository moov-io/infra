variable "gcp_creds_filepath" {
  default     = "~/.google/moov-sbx-223919-credentials.json"
  description = "Local filepath for Google Cloud credentials"
}

provider "google" {
  credentials = "${file(var.gcp_creds_filepath)}"
  project     = "moov-sbx-223919"
  region      = "us-central1"
}

# PROJECT_ID: moov-sbx-223919
# NAME: moov-sbx
# PROJECT_NUMBER: 215248738497
data "google_project" "moov-sbx-223919" {}

variable "env_name" {
  default = "sbx"
}

locals {
  project_name = "moov-${var.env_name}"
}

resource "google_project_services" "sbx" {
  project  = "${data.google_project.moov-sbx-223919.project_id}"

  services = [
    "bigquery-json.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

// All projects have this (default storage service account)
// We need to add a policy to the bucket created.
data "google_storage_project_service_account" "gcs_account" {}

locals {
  project_service_account_email = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  project_service_account_emails = "${list(local.project_service_account_email)}"
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

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # random_shuffle.zones returns with one of the original zones removed,
  # which becomes our primary zone.
  primary_gcp_zone = "${element(random_shuffle.zones.result, 0)}"
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
    command = "kubectl create clusterrolebinding moov-${var.env_name}-admin-binding --clusterrole=cluster-admin --user=${element(var.cluster_admins, count.index)}"
  }
}

variable "cluster_admins" {
  default = [
    "adam@moov.io",
    # "wade@moov.io",
  ]
}

locals {
  gcp_cluster_admin_emails = "${formatlist("user:%s", var.cluster_admins)}",
}
