resource "kubernetes_persistent_volume_claim" "alertmanager-data" {
  metadata {
    name      = "alertmanager-data"
    namespace = var.namespace
  }
  lifecycle {
    prevent_destroy = true
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.capacity
      }
    }
  }
}
