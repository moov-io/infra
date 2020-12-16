resource "kubernetes_persistent_volume_claim" "fed-data" {
  count = var.fed_data_capacity > 0 ? 1 : 0
  metadata {
    name = "fed-data"
    namespace = var.namespace
  }
  lifecycle {
    prevent_destroy = true
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.fed_data_capacity
      }
    }
  }
}
