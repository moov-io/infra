resource "kubernetes_service" "alertmanager" {
  metadata {
    name = "alertmanager"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "alertmanager"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }
  }
}

resource "kubernetes_service_account" "alertmanager" {
  metadata {
    name = "alertmanager"
    namespace = var.namespace
  }
}
