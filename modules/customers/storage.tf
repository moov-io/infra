resource "kubernetes_persistent_volume_claim" "customers-data" {
  metadata {
    name = "customers-data"
    namespace = var.namespace
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
