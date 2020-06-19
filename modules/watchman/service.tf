resource "kubernetes_service" "watchman" {
  metadata {
    name = "watchman"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "watchman"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
    port {
      name        = "metrics"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }
  }
}
