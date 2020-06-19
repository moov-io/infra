resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name = "data"
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
