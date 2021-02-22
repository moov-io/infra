resource "kubernetes_deployment" "alertmanager" {
  metadata {
    name = "alertmanager"
    namespace = var.namespace
    labels = {
      app = "alertmanager"
    }
  }
  spec {
    replicas = var.instances
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
      }
    }
    selector {
      match_labels = {
        app = "alertmanager"
      }
    }
    template {
      metadata {
        labels = {
          app = "alertmanager"
        }
        annotations = {
          "prometheus.io/path" = var.metrics_path
        }
      }
      spec {
        service_account_name = "alertmanager"
        termination_grace_period_seconds = 30
        container {
          image = "prom/alertmanager:${var.alertmanager_tag}"
          image_pull_policy = "Always"
          name = "alertmanager"
          args = concat(var.args, var.additional_args)
          volume_mount {
            name = "alertmanager-config"
            mount_path = "/opt/alertmanager/"
          }
          volume_mount {
            name = "alertmanager-data"
            mount_path = "/data/alertmanager/"
          }
          port {
            container_port = 9090
            name = "http"
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
            http_get {
              path = "/alertmanager/api/v2/status"
              port = 9090
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/alertmanager/api/v2/status"
              port = 9090
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          security_context {
            # TODO(adam): shouldn't need root
            # https://github.com/kubernetes/kubernetes/issues/2630
            run_as_user = 0
          }
        }
        volume {
          name = "alertmanager-config"
          secret {
            secret_name = "alertmanager-config"
          }
        }
        volume {
          name = "alertmanager-data"
          persistent_volume_claim {
            claim_name = "alertmanager-data"
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
