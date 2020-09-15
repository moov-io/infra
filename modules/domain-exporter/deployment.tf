resource "kubernetes_deployment" "domain-exporter" {
  metadata {
    name = "domain-exporter"
    namespace = var.namespace
    labels = {
      app = "domain-exporter"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "domain-exporter"
      }
    }
    template {
      metadata {
        labels = {
          app = "domain-exporter"
        }
      }
      spec {
        service_account_name = "domain-exporter"
        termination_grace_period_seconds = 30
        container {
          image = "quay.io/shift/domain_exporter:${var.image_tag}"
          image_pull_policy = "Always"
          name = "nginx-exporter"
          args = [
            "--config=/etc/domain-exporter/domains.yaml",
            "--bind=:9203",
            "--log.level=info",
          ]
          port {
            container_port = 9203
            name = "metrics"
            protocol = "TCP"
          }
          resources {
            limits {
              cpu    = "25m"
              memory = "50Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9203
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          liveness_probe {
            http_get {
              path = "/metrics"
              port = 9203
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem = true
            run_as_non_root = true
            run_as_user = 1000
          }
          volume_mount {
            name = "domain-exporter"
            mount_path = "/etc/domain-exporter"
            read_only = true
          }
        }
        volume {
          name = "domain-exporter"
          config_map {
            name = "domain-exporter"
            default_mode = "0644"
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
