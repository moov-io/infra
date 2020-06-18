resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "prometheus"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }
  }
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
  }
}
