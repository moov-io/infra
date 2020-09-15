resource "kubernetes_deployment" "infra-idx" {
  metadata {
    name = "infra-idx"
    namespace = var.namespace
    labels = {
      app = "infra-idx"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "infra-idx"
      }
    }
    template {
      metadata {
        labels = {
          app = "infra-idx"
        }
      }
      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
        service_account_name = "infra-idx"
        termination_grace_period_seconds = 30
        container {
          image = "nginx/nginx-prometheus-exporter:${var.nginx_exporter_tag}"
          image_pull_policy = "Always"
          name = "nginx-exporter"
          args = [
            "-nginx.scrape-uri=http://localhost:8080/stub_status",
          ]
          port {
            container_port = 9113
            name = "metrics"
            protocol = "TCP"
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "50Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9113
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/metrics"
              port = 9113
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            read_only_root_filesystem = true
            run_as_non_root = true
            run_as_user = 65534
          }
        }
        container {
          image = "moov/infra-idx:${var.infra_idx_tag}"
          image_pull_policy = "Always"
          name = "infra-idx"
          resources {
            limits {
              cpu    = "50m"
              memory = "25Mi"
            }
            requests {
              memory = "10Mi"
            }
          }
          port {
            container_port = 8080
            name = "proxy"
            protocol = "TCP"
          }
          volume_mount {
            name = "nginx-temp"
            mount_path = "/var/cache/nginx/"
          }
          volume_mount {
            name = "nginx-run"
            mount_path = "/var/run/"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem = true
            run_as_non_root = true
            run_as_user = 1000
          }
        }
        volume {
          name = "nginx-temp"
          empty_dir {}
        }
        volume {
          name = "nginx-run"
          empty_dir {}
        }
        restart_policy = "Always"
      }
    }
  }
}
