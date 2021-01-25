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
          image = var.docker_image
          image_pull_policy = "Always"
          name  = "fed"
          args = var.args
          env {
            name = "LOG_FORMAT"
            value = var.log_format
          }
          env {
            name = "FEDACH_DATA_PATH"
            value = var.fedach_data_path
          }
          env {
            name = "FEDWIRE_DATA_PATH"
            value = var.fedwire_data_path
          }
          volume_mount {
            name = "fed-data"
            mount_path = "/opt/fed/"
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
            limits = {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests = {
              memory = "25Mi"
            }
          }
          readiness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/live"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        volume {
          name = "fed-data"

          dynamic "persistent_volume_claim" {
            for_each = var.fed_data_capacity > 0 ? [1] : []
            content {
              claim_name = "fed-data"
            }
          }

          dynamic "empty_dir" {
            for_each = var.fed_data_capacity <= 0 ? [1] : []
            content { }
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
