resource "kubernetes_deployment" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
    namespace = var.namespace
    labels = {
      app = "kube-state-metrics"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "kube-state-metrics"
      }
    }
    template {
      metadata {
        labels = {
          app = "kube-state-metrics"
        }
      }
      spec {
        service_account_name = "kube-state-metrics"
        termination_grace_period_seconds = 30
        container {
          image = "quay.io/coreos/kube-state-metrics:${var.image_tag}"
          image_pull_policy = "Always"
          name = "kube-state-metrics"
          port {
            name = "http-metrics"
            container_port = 8080
          }
          port {
            name = "telemetry"
            container_port = 8081
          }
          resources {
            limits {
              memory = "100Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            timeout_seconds = 5
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            timeout_seconds = 5
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem = true
          }
        }
        container {
          image = "k8s.gcr.io/addon-resizer:${var.addon_tag}"
          image_pull_policy = "Always"
          name = "addon-resizer"
          command = [
            "/pod_nanny",
            "--container=kube-state-metrics",
            "--cpu=100m",
            "--extra-cpu=1m",
            "--memory=100Mi",
            "--extra-memory=2Mi",
            "--threshold=5",
            "--deployment=kube-state-metrics",
          ]
          resources {
            limits {
              memory = "50Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          env {
            name = "MY_POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "MY_POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
