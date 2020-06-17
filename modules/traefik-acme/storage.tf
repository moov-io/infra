resource "kubernetes_persistent_volume_claim" "traefik-acme" {
  metadata {
    name      = "traefik-acme"
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

output "volume_name" {
  value = ""
}
