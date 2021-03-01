# Create a KMS key
resource "google_kms_key_ring" "moov-terraform-state" {
  name     = "moov-terraform-state-keys"
  project  = var.gcp_project
  location = var.gcp_region

  depends_on = [google_project_service.ach]
}

resource "google_kms_key_ring_iam_binding" "key_ring" {
  key_ring_id = google_kms_key_ring.moov-terraform-state.self_link
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = sort(
    flatten(
      [
        local.project_service_account_emails,
        local.gcp_cluster_admin_emails,
      ],
    ),
  )
}

resource "google_kms_crypto_key" "moov-terraform-state" {
  name            = "moov-terraform-state"
  key_ring        = google_kms_key_ring.moov-terraform-state.self_link
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

# Attach the key to our IAM users
# Docs: https://cloud.google.com/kms/docs/iam#granting_permissions_to_use_keys
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.moov-terraform-state.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = sort(
    flatten(
      [
        local.project_service_account_emails,
        local.gcp_cluster_admin_emails,
      ],
    ),
  )
}

# Create our bucket
resource "google_storage_bucket" "tf-state-storage" {
  name     = "moov-terraform-state"
  location = var.gcp_region

  force_destroy = false
  project       = var.gcp_project
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.moov-terraform-state.self_link
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Add bucket to IAM
resource "google_storage_bucket_iam_binding" "tf-state-storage" {
  bucket = google_storage_bucket.tf-state-storage.name
  role   = "roles/storage.objectAdmin"
  members = sort(
    flatten(
      [
        local.project_service_account_emails,
        local.gcp_cluster_admin_emails,
      ],
    ),
  )
}

# Setup GCS backend
# TODO(adam): module out to break cyclic dep (if we re-created from scratch)
terraform {
  backend "gcs" {
    bucket      = "moov-terraform-state"
    prefix      = "sbx/terraform/state"
    credentials = "~/.google/credentials.json"
    # encryption_key = ""
  }
  required_providers {
    aws = ">= 2.13"
    google = "~> 2.7"
    kubernetes = ">= 1.7, < 2.0.0"
    random = "> 2.1"
    null = "> 2.1"
  }
  required_version = ">= 0.12"
}
