# Create a KMS key
resource "google_kms_key_ring" "moov-terraform-state" {
  name     = "moov-${var.env_name}-terraform-state-keys"
  project  = "${data.google_project.moov-sbx-223919.project_id}"
  location = "us-central1"

  depends_on = ["google_project_services.sbx"]
}

resource "google_kms_key_ring_iam_binding" "key_ring" {
  key_ring_id = "${google_kms_key_ring.moov-terraform-state.self_link}"
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members     = [
    "${sort(flatten(list(local.project_service_account_emails, local.gcp_cluster_admin_emails)))}",
  ]
}

resource "google_kms_crypto_key" "moov-terraform-state" {
  name            = "moov-${var.env_name}terraform-state"
  key_ring        = "${google_kms_key_ring.moov-terraform-state.self_link}"
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

# Attach the key to our IAM users
# Docs: https://cloud.google.com/kms/docs/iam#granting_permissions_to_use_keys
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = "${google_kms_crypto_key.moov-terraform-state.self_link}"
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members       = [
    "${sort(flatten(list(local.project_service_account_emails, local.gcp_cluster_admin_emails)))}",
  ]
}

# Create our bucket
resource "google_storage_bucket" "tf-state-storage" {
  name     = "moov-${var.env_name}-terraform-state"
  location = "us-central1"

  force_destroy = false
  project       = "${data.google_project.moov-sbx-223919.project_id}"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = "${google_kms_crypto_key.moov-terraform-state.self_link}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Add bucket to IAM
resource "google_storage_bucket_iam_binding" "tf-state-storage" {
  bucket  = "${google_storage_bucket.tf-state-storage.name}"
  role    = "roles/storage.objectAdmin"
  members = [
    "${sort(flatten(list(local.project_service_account_emails, local.gcp_cluster_admin_emails)))}",
  ]
}

# Setup GCS backend # TODO(adam): uncomment to save tfstate in storage
# terraform {
#   backend "gcs" {
#     bucket  = "moov-sbx-terraform-state"
#     prefix  = "sbx/terraform/state"
#     credentials = "~/.google/moov-sbx-223919-credentials.json"
#     # encryption_key = "" # TODO(adam)
#   }
#   version = "> 0.11"
# }
