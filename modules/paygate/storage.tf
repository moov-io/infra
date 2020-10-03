resource "kubernetes_persistent_volume_claim" "data" {
  count = var.sqlite_enabled ? 1 : 0
  metadata {
    name = "paygate"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.sqlite_capacity
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "merging" {
  metadata {
    name = "paygate-merging"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.merging_capacity
      }
    }
  }
}
