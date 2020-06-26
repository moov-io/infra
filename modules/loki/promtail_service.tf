resource "kubernetes_service" "promtail" {
  metadata {
    name = "promtail"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "promtail"
    }
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 9095
      target_port = 9095
    }
  }
}

resource "kubernetes_service_account" "promtail" {
  metadata {
    name = "promtail"
    namespace = var.namespace
  }
}
