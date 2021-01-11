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
          image = var.sftp_image
          image_pull_policy = "Always"
          name  = "sftp"
          command = [
            "/bin/sh"
          ]
          args = [
            "-c",
            "set -x; mkdir -p /home/demo/upload/inbound/ /home/demo/upload/outbound/ /home/demo/upload/returned/; chown -R 1000:100 /home/demo/upload; /entrypoint demo:password:::upload;"
          ]
          volume_mount {
            name = "sftp-data"
            mount_path = "/home/demo/upload/"
          }
          port {
            container_port = 22
            name = "sftp"
            protocol = "TCP"
          }
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
        container {
          image = var.nginx_image
          image_pull_policy = "Always"
          name = "nginx"
          args = [
            "nginx", "-c", "/opt/nginx/nginx.conf"
          ]
          volume_mount {
            name = "nginx-conf"
            mount_path = "/opt/nginx/"
          }
          volume_mount {
            name = "sftp-data"
            mount_path = "/usr/share/nginx/www/"
          }
          port {
            container_port = 8080
            name = "http"
            protocol = "TCP"
          }
        }
        volume {
          name = "nginx-conf"
          config_map {
            name = "sftp-nginx-config"
          }
        }
        volume {
          name = "sftp-data"
          empty_dir {}
        }
        restart_policy = "Always"
      }
    }
  }
}
