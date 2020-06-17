resource "kubernetes_service" "traefik" {
  metadata {
    name = "traefik"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "traefik"
    }
    session_affinity = "LoadBalancer"
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
    type = "LoadBalancer"
  }
}

resource "kubernetes_service_account" "traefik" {
  metadata {
    name = "traefik"
    namespace = var.namespace
  }
}
