variable "kubernetes_username" {}
variable "kubernetes_password" {}

variable "node_disk_size_gb" {
  default = 25
}
variable "node_disk_type" {
  default = "pd-standard"
}
variable "node_machine_counts" {
  type = "map"
  default = {
    "g1-small" = 0
    "n1-standard-1" = 0
  }
}
variable "node_preemptible" {
  default = false
}

# Setup for a GCP kubernetes cluster.
resource "google_container_cluster" "sbx" {
  name               = "sbx"
  zone               = "us-central1-b"
  initial_node_count = 3

  additional_zones = [
    "us-central1-a",
    "us-central1-c",
  ]

  min_master_version = "1.10.7-gke.1" # TODO(adam): This will change overtime.

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  master_auth {
    username = "${var.kubernetes_username}"
    password = "${var.kubernetes_password}"
  }

  node_pool {
    name = "sbx-initial-node-pool"
  }

  node_config {
    disk_size_gb = "${var.node_disk_size_gb}"
    disk_type    = "${var.node_disk_type}"
    machine_type = "${lookup(var.node_machine_counts, "g1-small")}"
    preemptible  = "${var.node_preemptible}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}

resource "google_container_node_pool" "sbx" {
  name       = "sbx-node-pool"
  zone       = "us-central1-b"
  cluster    = "${google_container_cluster.sbx.name}"
  node_count = 0

  node_config {
    disk_size_gb = "${var.node_disk_size_gb}"
    disk_type    = "${var.node_disk_type}"
    machine_type = "${lookup(var.node_machine_counts, "g1-small")}"
    preemptible  = "${var.node_preemptible}"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }
}

resource "null_resource" "local_credential_write" {
  provisioner "local-exec" {
    command = "mkdir -p .gcp/"
  }
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.sbx.master_auth.0.client_certificate}' > .gcp/client.crt"
  }
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.sbx.master_auth.0.client_key}' > .gcp/client.key"
  }
  provisioner "local-exec" {
    command = "echo '${google_container_cluster.sbx.master_auth.0.cluster_ca_certificate}' > .gcp/ca.crt"
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.sbx.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.sbx.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.sbx.master_auth.0.cluster_ca_certificate}"
}

provider "kubernetes" {
  host = "${google_container_cluster.sbx.endpoint}"

  # client_certificate     = "${file("~/.kube/client-cert.pem")}"
  # client_key             = "${file("~/.kube/client-key.pem")}"
  # cluster_ca_certificate = "${file("~/.kube/cluster-ca-cert.pem")}"

  client_certificate = "${google_container_cluster.sbx.master_auth.0.client_certificate}"
  client_key = "${google_container_cluster.sbx.master_auth.0.client_key}"
  cluster_ca_certificate = "${google_container_cluster.sbx.master_auth.0.cluster_ca_certificate}"
}
