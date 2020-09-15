resource "kubernetes_daemonset" "node-exporter" {
  metadata {
    name = "node-exporter"
    namespace = var.namespace
    labels = {
      app = "node-exporter"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "node-exporter"
      }
    }
    template {
      metadata {
        labels = {
          app = "node-exporter"
        }
      }
      spec {
        service_account_name = "node-exporter"
        automount_service_account_token = true
        container {
          image = "quay.io/prometheus/node-exporter:${var.image_tag}"
          image_pull_policy = "Always"
          name = "node-exporter"
          args = [
            "--web.listen-address=:9100",
            "--path.procfs=/host/proc",
            "--path.sysfs=/host/sys",
            "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)",
            "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$",
          ]
          port {
            host_port = 9100
            container_port = 9100
            name = "metrics"
          }
          resources {
            limits {
              cpu    = "50m"
              memory = "50Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          volume_mount {
            mount_path = "/host/proc"
            name = "proc"
            read_only = true
          }
          volume_mount {
            mount_path = "/host/sys"
            name = "sys"
            read_only = true
          }
          volume_mount {
            mount_path = "/host/root"
            mount_propagation = "HostToContainer"
            name = "root"
            read_only = true
          }
        }
        host_network = true
        host_pid = true
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        security_context {
          run_as_non_root = true
          run_as_user = 65534
        }
        toleration {
          effect = "NoSchedule"
          key = "node-role.kubernetes.io/master"
        }
        volume {
          name = "proc"
          host_path {
            path = "/proc"
          }
        }
        volume {
          name = "sys"
          host_path {
            path = "/sys"
          }
        }
        volume {
          name = "root"
          host_path {
            path = "/"
          }
        }
      }
    }
  }
}
