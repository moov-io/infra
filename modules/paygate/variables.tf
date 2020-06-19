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

variable "capacity" {
  default = "1Gi"
}
