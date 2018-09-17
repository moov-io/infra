// Configure the Google Cloud provider
provider "google" {
  credentials = "${file(var.gcp_creds_filepath)}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

variable "gcp_creds_filepath" {
  default = "~/.google/credentials.json"
  description = "Local filepath for Google Cloud credentials"
}

variable "gcp_project" {
  default = "automated-clearing-house"
  description = "Google Cloud project name"
}

variable "gcp_region" {
  default = "us-central1"
}
