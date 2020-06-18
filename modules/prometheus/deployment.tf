resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
    labels = {
      app = "prometheus"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        service_account_name = "prometheus"
        # priorityClassName: high-priority # TODO(adam): need to setup this
        termination_grace_period_seconds = 30
        automount_service_account_token = true
        container {
          image = "prom/prometheus:${var.image_tag}"
          image_pull_policy = "Always"
          name = "prometheus"
          args = concat(var.args, var.additional_args)
          volume_mount {
            name = "prometheus-config"
            mount_path = "/opt/prometheus/"
          }
          volume_mount {
            name = "prometheus-rules"
            mount_path = "/opt/prometheus-rules/"
          }
          volume_mount {
            name = "prometheus-data"
            mount_path = "/prometheus"
          }
          port {
            container_port = 9090
            name = "http"
            protocol = "TCP"
          }
          resources {
            limits {
              memory = "3000Mi"
            }
            requests {
              memory = "2000Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "${var.base_path}/ready"
              port = 9090
            }
            initial_delay_seconds = 60
            period_seconds = 10
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 5
          }
          liveness_probe {
            http_get {
              path = "${var.base_path}/ready"
              port = 9090
            }
            initial_delay_seconds = 60
            period_seconds = 10
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 5
          }
        }
        security_context {
          # TODO(adam): shouldn't need root -- https://github.com/kubernetes/kubernetes/issues/2630
          run_as_user = 0
        }
        volume {
          name = "prometheus-config"
          config_map {
            name = "prometheus-config"
            items {
              key = "prometheus.yaml"
              path = "prometheus.yaml"
            }
          }
        }
        volume {
          name = "prometheus-rules"
          config_map {
            name = "prometheus-rules"
            # TODO(adam): Do we need to specify each key/value
          }
        }
        volume {
          name = "prometheus-data"
          persistent_volume_claim {
            claim_name = "prometheus-data"
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
