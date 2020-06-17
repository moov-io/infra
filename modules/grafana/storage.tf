resource "kubernetes_persistent_volume_claim" "grafana-data" {
  metadata {
    name      = "grafana-data"
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
