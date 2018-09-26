provider "kubernetes" {
  host = "${google_container_cluster.primary.endpoint}"

  username = "${var.username}"
  password = "${var.password}"

  # client_certificate = "${base64decode(file("client.crt"))}"
  # client_key = "${base64decode(file("client.key"))}"
  # cluster_ca_certificate = "${base64decode(file("ca.crt"))}"
}


variable "cluster_name" {
  default = "sbx"
}

variable "username" {}
variable "password" {}

variable "primary_pool_node_count" {
  default = 3
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

# Setup for a GCP kubernetes cluster.
resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${local.primary_gcp_zone}"
  initial_node_count = 1

  min_master_version = "${var.min_master_version}"

  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }

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

  lifecycle {
    prevent_destroy = true
  }

  node_count = "${max(1, var.primary_pool_node_count - 1)}"
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

resource "null_resource" "kubernetes_config_save" {
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.primary.master_auth.0.client_certificate}' > client.crt"
  }
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.primary.master_auth.0.client_key}' > client.key"
  }
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}' > ca.crt"
  }
}
