resource "kubernetes_deployment" "sftp" {
  metadata {
    name = "sftp"
    namespace = var.namespace
    labels = {
      app = "sftp"
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
        app = "sftp"
      }
    }
    template {
      metadata {
        labels = {
          app = "sftp"
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
          image = "atmoz/sftp:${var.tag}"
          image_pull_policy = "Always"
          name  = "sftp"
          command = [
            "/bin/sh"
          ]
          args = [
            "-c",
            "set -x; mkdir -p /home/demo/upload/inbound/ /home/demo/upload/outbound/ /home/demo/upload/returned/; chown -R 1000:100 /home/demo/upload; /entrypoint demo:password:::upload;"
          ]
          port {
            container_port = 22
            name = "sftp"
            protocol = "TCP"
          }
          # resources {
          #   limits {
          #     cpu    = "100m"
          #     memory = "100Mi"
          #   }
          #   requests {
          #     cpu    = "25m"
          #     memory = "25Mi"
          #   }
          # }
          readiness_probe {
            tcp_socket {
              port = 22
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            tcp_socket {
              port = 22
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
