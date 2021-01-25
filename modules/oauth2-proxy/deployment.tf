resource "kubernetes_deployment" "oauth2-proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = var.namespace
    labels = {
      app = "oauth2-proxy"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "oauth2-proxy"
      }
    }
    template {
      metadata {
        labels = {
          app = "oauth2-proxy"
        }
      }
      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
        service_account_name = "oauth2-proxy"
        termination_grace_period_seconds = 30
        container {
          image = "quay.io/oauth2-proxy/oauth2-proxy:${var.image_tag}"
          image_pull_policy = "Always"
          name = "oauth2-proxy"
          args = var.container_arguments
          env {
            name = "OAUTH2_PROXY_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = "oauth2-proxy-config"
                key  = "client_id"
              }
            }
          }
          env {
            name = "OAUTH2_PROXY_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = "oauth2-proxy-config"
                key  = "client_secret"
              }
            }
          }
          env {
            name = "OAUTH2_PROXY_COOKIE_SECRET"
            value_from {
              secret_key_ref {
                name = "oauth2-proxy-config"
                key  = "cookie_secret"
              }
            }
          }
          resources {
            limits = {
              cpu    = "50m"
              memory = "25Mi"
            }
            requests = {
              memory = "10Mi"
            }
          }
          port {
            container_port = 4180
            name = "proxy"
            protocol = "TCP"
          }
          readiness_probe {
            http_get {
              path = "/ping"
              port = 4180
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/ping"
              port = 4180
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            read_only_root_filesystem = true
            run_as_non_root = true
            run_as_user = 2000
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
