variable "cluster_name" {
  default = "sbx"
}

variable "username" {}
variable "password" {}

variable "primary_pool_node_count" {
  default = 0
}
variable "secondary_pool_node_count" {
  default = 0
}
variable "secondary_pool_count" {
  default = 0
}

variable "node_disk_size_gb" {
  default = 25
}
variable "node_disk_type" {
  default = "pd-standard"
}

variable "node_machine_type" {
  default = "g1-small"
}

variable "node_preemptible" {
  default = true
}

variable "min_master_version" {
  default = "1.10.7-gke.1"
}

locals {
  # random_shuffle.zones returns with one of the original zones removed,
  # which becomes our primary zone.
  primary_gcp_zone = "${element(random_shuffle.zones.result, 0)}"

  # secondary_gcp_zones is a list of var.gcp_zones, but with the primary removed.
  secondary_gcp_zones = "${compact(split(",", replace(join(",", random_shuffle.zones.result), "${local.primary_gcp_zone}", "")))}"
}


# Setup for a GCP kubernetes cluster.
resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${local.primary_gcp_zone}"
  initial_node_count = 1

  min_master_version = "${var.min_master_version}"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }

  node_config {
    disk_size_gb = "${var.node_disk_size_gb}"
    disk_type    = "${var.node_disk_type}"
    machine_type = "${var.node_machine_type}"
    preemptible  = "${var.node_preemptible}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-primary-nodes"
  zone       = "${local.primary_gcp_zone}"
  cluster    = "${google_container_cluster.primary.name}"

  node_count = "${max(0, var.primary_pool_node_count - 1)}"
  node_config {
    disk_size_gb = "${var.node_disk_size_gb}"
    disk_type    = "${var.node_disk_type}"
    machine_type = "${var.node_machine_type}"
    preemptible  = "${var.node_preemptible}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}

resource "google_container_node_pool" "secondary" {
  name    = "${var.cluster_name}-secondary-nodes"
  cluster = "${google_container_cluster.primary.name}"

  count = "${var.secondary_pool_count}"
  zone  = "${element(local.secondary_gcp_zones, count.index)}"

  node_count = "${var.secondary_pool_node_count}"
  node_config {
    disk_size_gb = "${var.node_disk_size_gb}"
    disk_type    = "${var.node_disk_type}"
    machine_type = "${var.node_machine_type}"
    preemptible  = "${var.node_preemptible}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}

resource "null_resource" "kubectl_setup" {
  # Call out to gcloud, which writes kubectl configs
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.zone} --project ${var.gcp_project}"
  }
}


output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}


provider "kubernetes" {
  host = "${google_container_cluster.primary.endpoint}"

  client_certificate = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  client_key = "${google_container_cluster.primary.master_auth.0.client_key}"
  cluster_ca_certificate = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
