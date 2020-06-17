resource "kubernetes_service" "oauth2-proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "oauth2-proxy"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 4180
      target_port = 4180
    }
  }
}

resource "kubernetes_service_account" "oauth2-proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = var.namespace
  }
}
