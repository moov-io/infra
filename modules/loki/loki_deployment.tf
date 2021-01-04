locals {
  computed_args = compact([
    var.base_path != "" ? "-server.path-prefix=${var.base_path}" : ""
  ])
}

resource "kubernetes_deployment" "loki" {
  metadata {
    name = "loki"
    namespace = var.namespace
    labels = {
      app = "loki"
    }
  }
  spec {
    replicas = var.loki_instances
    selector {
      match_labels = {
        app = "loki"
      }
    }
    template {
      metadata {
        labels = {
          app = "loki"
        }
      }
      spec {
        service_account_name = "loki"
        automount_service_account_token = true
        termination_grace_period_seconds = 30
        container {
          image = "grafana/loki:${var.loki_tag}"
          image_pull_policy = "Always"
          name = "loki"
          args = concat(var.loki_args, local.computed_args)
          volume_mount {
            name = "loki-config"
            mount_path = "/etc/loki/"
          }
          volume_mount {
            name = "loki-data"
            mount_path = "/loki"
          }
          port {
            container_port = 3100
            name = "http"
            protocol = "TCP"
          }
          resources {
            limits {
              cpu    = "250m"
              memory = "250Mi"
            }
            requests {
              memory = "100Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "${var.base_path}/ready"
              port = 3100
            }
            initial_delay_seconds = 45
          }
          liveness_probe {
            http_get {
              path = "${var.base_path}/ready"
              port = 3100
            }
            initial_delay_seconds = 45
          }
        }
        security_context {
          fs_group = 10001
          run_as_group = 10001
          run_as_non_root = true
          run_as_user = 10001
        }
        volume {
          name = "loki-config"
          config_map {
            name = "loki-config"
            items {
              key = "loki.yaml"
              path = "loki.yaml"
            }
          }
        }
        volume {
          name = "loki-data"
          persistent_volume_claim {
            claim_name = "loki-data"
          }
        }
        restart_policy = "Always"
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
      }
    }
  }
}
