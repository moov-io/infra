resource "kubernetes_daemonset" "promtail" {
  metadata {
    name = "promtail"
    namespace = var.namespace
    labels = {
      app = "promtail"
    }
  }
  spec {
    min_ready_seconds = 10
    selector {
      match_labels = {
        app = "promtail"
      }
    }
    template {
      metadata {
        labels = {
          app = "promtail"
        }
      }
      spec {
        service_account_name = "promtail"
        automount_service_account_token = true
        container {
          image = "grafana/promtail:${var.promtail_tag}"
          image_pull_policy = "Always"
          name = "promtail"
          args = var.promtail_args
          port {
            container_port = 80
            name = "http-metrics"
          }
          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          resources {
            limits = {
              cpu    = "250m"
              memory = "50Mi"
            }
            requests = {
              memory = "25Mi"
            }
          }
          security_context {
            privileged = true
            run_as_user = 0 // TODO(adam): run as non-root
          }
          volume_mount {
            mount_path = "/etc/promtail"
            name = "promtail-config"
          }
          volume_mount {
            mount_path = "/var/log"
            name = "varlog"
          }
          volume_mount {
            mount_path = "/var/lib/docker/containers"
            name = "varlibdockercontainers"
            read_only = true
          }
        }
        toleration {
          effect = "NoSchedule"
          operator = "Exists"
        }
        volume {
          name = "promtail-config"
          config_map {
            name = "promtail-config"
            items {
              key = "promtail.yaml"
              path = "promtail.yaml"
            }
          }
        }
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}
