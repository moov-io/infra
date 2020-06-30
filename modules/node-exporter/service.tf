resource "kubernetes_service" "node-exporter" {
  metadata {
    name = "node-exporter"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "node-exporter"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9100
      target_port = 9100
    }
  }
}

resource "kubernetes_service_account" "node-exporter" {
  metadata {
    name = "node-exporter"
    namespace = var.namespace
  }
}
