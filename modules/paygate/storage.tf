resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name = "paygate"
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
