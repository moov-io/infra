resource "kubernetes_persistent_volume_claim" "traefik-acme" {
  metadata {
    name      = "traefik-${var.stage}-acme"
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
