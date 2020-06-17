resource "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "traefik"
    }
    type = "LoadBalancer"
    external_traffic_policy = "Local"
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    port {
      name        = "proxy"
      protocol    = "TCP"
      port        = 443
      target_port = 443
    }
  }
}

resource "kubernetes_service_account" "traefik" {
  metadata {
    name = "traefik"
    namespace = var.namespace
  }
}
