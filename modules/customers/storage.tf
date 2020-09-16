resource "kubernetes_persistent_volume_claim" "data" {
  count = var.database_type == "sqlite" ? 1 : 0
  metadata {
    name = "customers"
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
