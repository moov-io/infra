resource "kubernetes_daemonset" "cadvisor" {
  metadata {
    name = "cadvisor"
    namespace = var.namespace
    annotations = {
      "seccomp.security.alpha.kubernetes.io/pod" = "docker/default"
    }
    labels = {
      app = "cadvisor"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "cadvisor"
        name = "cadvisor"
      }
    }
    template {
      metadata {
        labels = {
          app = "cadvisor"
          name = "cadvisor"
        }
      }
      spec {
        service_account_name = "cadvisor"
        automount_service_account_token = false
        container {
          image = var.docker_image
          image_pull_policy = "Always"
          name = "cadvisor"
          args = [
            "-listen_ip=0.0.0.0",
            "-port=8080",
            "-logtostderr",
            # "-disable_metrics=disk,network,tcp,udp,percpu,sched",
          ]
          port {
            host_port = 8080
            container_port = 8080
            name = "metrics"
          }
          resources {
            limits = {
              memory = "200Mi"
            }
            requests = {
              memory = "200Mi"
            }
          }
          volume_mount {
            mount_path = "/rootfs"
            name = "rootfs"
            read_only = true
          }
          volume_mount {
            mount_path = "/var/run"
            name = "var-run"
            read_only = true
          }
          volume_mount {
            mount_path = "/sys"
            name = "sys"
            read_only = true
          }
          volume_mount {
            mount_path = "/var/lib/docker"
            name = "docker"
            read_only = true
          }
          volume_mount {
            mount_path = "/dev/disk"
            name = "disk"
            read_only = true
          }
        }
        volume {
          name = "rootfs"
          host_path {
            path = "/"
          }
        }
        volume {
          name = "var-run"
          host_path {
            path = "/var/run"
          }
        }
        volume {
          name = "sys"
          host_path {
            path = "/sys"
          }
        }
        volume {
          name = "docker"
          host_path {
            path = "/var/lib/docker"
          }
        }
        volume {
          name = "disk"
          host_path {
            path = "/dev/disk"
          }
        }
      }
    }
  }
}
