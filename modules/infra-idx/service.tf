resource "kubernetes_service" "infra-idx" {
  metadata {
    name = "infra-idx"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "infra-idx"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service_account" "infra-idx" {
  metadata {
    name = "infra-idx"
    namespace = var.namespace
  }
}
