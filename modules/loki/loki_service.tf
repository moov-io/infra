resource "kubernetes_service" "loki" {
  metadata {
    name = "loki"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "loki"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 3100
      target_port = 3100
    }
  }
}

resource "kubernetes_service_account" "loki" {
  metadata {
    name = "loki"
    namespace = var.namespace
  }
}
