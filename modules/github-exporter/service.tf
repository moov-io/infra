resource "kubernetes_service" "github-exporter" {
  metadata {
    name = "github-exporter"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "github-exporter"
    }
    port {
      name        = "metrics"
      port        = 9171
      target_port = 9171
      protocol    = "TCP"
    }
  }
}
