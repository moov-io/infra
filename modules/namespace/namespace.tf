variable "name" {}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.name
  }
}

output "name" {
  value = var.name
}
