resource "google_service_account" "mysql_backup" {
    account_id   = "mysql-production-backups"
    display_name = "mysql production backups"
}

resource "google_kms_key_ring" "mysql_backup" {
  name     = "moov-mysql-backup-key"
  project  = var.gcp_project
  location = var.gcp_region

  depends_on = [google_project_services.ach]
}

resource "google_kms_key_ring_iam_binding" "mysql_backup_key_ring" {
  key_ring_id = google_kms_key_ring.mysql_backup.self_link
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

resource "google_kms_crypto_key" "mysql_backup" {
  name            = "moov-mysql-backup"
  key_ring        = google_kms_key_ring.mysql_backup.self_link
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

# Attach the key to our IAM users
# Docs: https://cloud.google.com/kms/docs/iam#granting_permissions_to_use_keys
resource "google_kms_crypto_key_iam_binding" "mysql_backup_crypto_key" {
  crypto_key_id = google_kms_crypto_key.mysql_backup.self_link
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

resource "google_storage_bucket" "mysql_backups" {
  name     = "moov-production-mysql-backups"
  location = var.gcp_region

  force_destroy = false
  project       = var.gcp_project
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.mysql_backup.self_link
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_binding" "mysql_backup" {
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
