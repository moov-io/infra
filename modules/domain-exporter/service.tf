resource "kubernetes_service" "domain-exporter" {
  metadata {
    name = "domain-exporter"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "domain-exporter"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9203
      target_port = 9203
    }
  }
}

resource "kubernetes_service_account" "domain-exporter" {
  metadata {
    name = "domain-exporter"
    namespace = var.namespace
  }
}
