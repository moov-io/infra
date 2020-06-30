resource "kubernetes_service" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
    namespace = var.namespace
    labels = {
      k8s-app = "kube-state-metrcs"
    }
    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      k8s-app = "kube-state-metrics"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
    port {
      name        = "telemetry"
      protocol    = "TCP"
      port        = 8081
      target_port = 8081
    }
  }
}

resource "kubernetes_service_account" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
    namespace = var.namespace
  }
}
