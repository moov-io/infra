resource "kubernetes_deployment" "watchman" {
  metadata {
    name = "watchman"
    namespace = var.namespace
    labels = {
      app = "watchman"
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
        app = "watchman"
      }
    }
    template {
      metadata {
        labels = {
          app = "watchman"
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
          image = "moov/watchman:${var.tag}"
          image_pull_policy = "Always"
          name  = "watchman"
          args = [
            "-http.addr=:8080",
            "-admin.addr=:9090",
          ]
          env {
            name = "LOG_FORMAT"
            value = "plain"
          }
          env {
            name = "DATABASE_TYPE"
            value = var.database_type
          }
          env {
            name = "MYSQL_USER"
            value = var.mysql_user
          }
          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = "watchman-mysql"
                key = "password"
              }
            }
          }
          env {
            name = "MYSQL_ADDRESS"
            value = var.mysql_address
          }
          env {
            name = "MYSQL_DATABASE"
            value = var.mysql_database
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
              cpu    = var.resources_cpu_limit
              memory = var.resources_mem_limit
            }
            requests = {
              cpu    = var.resources_cpu_request
              memory = var.resources_mem_request
            }
          }
          readiness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 5
          }
          liveness_probe {
            http_get {
              path = "/live"
              port = 9090
            }
            initial_delay_seconds = 10
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 5
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
