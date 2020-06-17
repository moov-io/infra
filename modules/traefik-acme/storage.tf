resource "kubernetes_persistent_volume_claim" "traefik-acme" {
  metadata {
    name      = "terraform-acme"
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
