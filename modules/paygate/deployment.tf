resource "kubernetes_deployment" "paygate" {
  depends_on = [
    kubernetes_secret.paygate-config,
    kubernetes_secret.paygate-google-application-credentials,
    kubernetes_secret.paygate-audit-trail-gpg-key,
  ]

  metadata {
    name = "paygate"
    namespace = var.namespace
    labels = {
      app = "paygate"
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
        app = "paygate"
      }
    }
    template {
      metadata {
        labels = {
          app = "paygate"
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
        volume {
          name = "paygate-config"
          secret {
            secret_name = "paygate-config"
          }
        }
        volume {
          name = "paygate-preupload-gpg-key"
          secret {
            secret_name = "paygate-preupload-gpg-key"
          }
        }
        volume {
          name = "paygate-audit-trail-gpg-key"
          secret {
            secret_name = "paygate-audit-trail-gpg-key"
          }
        }
        container {
          image = "moov/paygate:${var.tag}"
          image_pull_policy = "Always"
          name  = "paygate"
          args = [
            "-config=/opt/moov/paygate/conf/config.yaml",
          ]
          env {
            name = "GOOGLE_APPLICATION_CREDENTIALS"
            value_from {
              secret_key_ref {
                name = "paygate-google-application-credentials"
                key = "credentials.json"
              }
            }
          }
          port {
            container_port = 8080
            name = "http"
            protocol = "TCP"
          }
          port {
            container_port = 9090
            name = "metrics"
            protocol = "TCP"
          }
          volume_mount {
            name = "paygate-config"
            mount_path = "/opt/moov/paygate/conf/"
          }
          volume_mount {
            name = "paygate-preupload-gpg-key"
            mount_path = "/conf/keys/"
          }
          volume_mount {
            name = "paygate-audit-trail-gpg-key"
            mount_path = "/conf/audit/"
          }
          volume_mount {
            name = "paygate"
            mount_path = "/opt/moov/paygate/"
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests {
              memory = "25Mi"
            }
          }
          readiness_probe {
            http_get {
              # path = "/ping"
              # port = 8080
              path = "/version"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              # path = "/ping"
              # port = 8080
              path = "/version"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        volume {
          name = "paygate"
          persistent_volume_claim {
            claim_name = "paygate"
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
