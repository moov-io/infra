variable "tag" {
  default = "latest"
}

variable "namespace" {}

variable "config_filepath" {}

variable "pre_upload_gpg_public_key_file" {}

variable "pre_upload_gpg_public_signing_key_file" {}

variable "google_application_credentials_filepath" {}
variable "audit_trail_gpg_key_file" {}

variable "instances" {
  default = 1
}

variable "sqlite_capacity" {
  default = "1Gi"
}
variable "sqlite_enabled" {
  default = true
}

variable "merging_capacity" {
  default = "5Gi"
}
