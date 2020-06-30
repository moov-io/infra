resource "kubernetes_service" "cadvisor" {
  metadata {
    name = "cadvisor"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "cadvisor"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service_account" "cadvisor" {
  metadata {
    name = "cadvisor"
    namespace = var.namespace
  }
}
