resource "kubernetes_deployment" "github-exporter" {
  metadata {
    name = "github-exporter"
    namespace = var.namespace
    labels = {
      app = "github-exporter"
    }
  }
  spec {
    replicas = 1
    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }
    selector {
      match_labels = {
        app = "github-exporter"
      }
    }
    template {
      metadata {
        labels = {
          app = "github-exporter"
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
          image = "infinityworks/github-exporter:${var.tag}"
          image_pull_policy = "Always"
          name  = "github-exporter"
          env {
            name = "ORGS"
            value = var.orgs
          }
          env {
            name = "GITHUB_TOKEN"
            value_from {
              secret_key_ref {
                name = "github-exporter"
                key = "github-token"
              }
            }
          }
          port {
            container_port = 9171
            name = "http"
            protocol = "TCP"
          }
          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9171
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/metrics"
              port = 9171
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
