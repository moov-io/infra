resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name      = "prometheus-data"
    namespace = var.namespace
  }
  lifecycle {
    prevent_destroy = true
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_capacity
      }
    }
  }
}
