resource "kubernetes_deployment" "fed" {
  metadata {
    name = "fed"
    namespace = var.namespace
    labels = {
      app = "fed"
    }
  }
  spec {
    replicas = var.instances
    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }
    selector {
      match_labels = {
        app = "fed"
      }
    }
    template {
      metadata {
        labels = {
          app = "fed"
        }
      }
      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
              }
              weight = 1
            }
          }
        }
        container {
          image = "moov/fed:${var.tag}"
          image_pull_policy = "Always"
          name  = "fed"
          args = [
            "-http.addr=:8080",
            "-admin.addr=:9090",
          ]
          env {
            name = "LOG_FORMAT"
            value = "plain"
          }
          port {
            container_port = 8080
            name = "http"
            protocol = "TCP"
          }
          port {
            container_port = 9090
            name = "metrics"
            protocol = "TCP"
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests {
              cpu    = "25m"
              memory = "25Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "/ping"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/ping"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
