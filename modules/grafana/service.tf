resource "kubernetes_service" "grafana" {
  metadata {
    name = "grafana"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "grafana"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }
  }
}

resource "kubernetes_service_account" "grafana" {
  metadata {
    name = "grafana"
    namespace = var.namespace
  }
}
