resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"
    namespace = var.namespace
    labels = {
      app = "grafana"
    }
  }
  spec {
    replicas = var.instances
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }
      spec {
        service_account_name = "grafana"
        termination_grace_period_seconds = 30
        container {
          image = "nginx:${var.nginx_tag}"
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
            name = "nginx-temp"
            mount_path = "/var/cache/nginx/"
          }
          volume_mount {
            name = "nginx-www"
            mount_path = "/usr/share/nginx/www/"
          }
          port {
            container_port = 9090
            name = "http"
            protocol = "TCP"
          }
        }
        container {
          image = "nginx/nginx-prometheus-exporter:${var.nginx_exporter_tag}"
          image_pull_policy = "Always"
          name = "nginx-exporter"
          args = [
            "-nginx.scrape-uri=http://localhost:9090/stub_status",
          ]
          port {
            container_port = 9113
            name = "metrics"
            protocol = "TCP"
          }
          resources {
            limits {
              memory = var.resources_memory_limit
            }
            requests {
              memory = var.resources_memory_request
            }
          }
          readiness_probe {
            http_get {
              path = "/metrics"
              port = 9113
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/metrics"
              port = 9113
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          security_context {
            read_only_root_filesystem = true
            run_as_non_root = true
            run_as_user = 65534
          }
        }
        container {
          image = "grafana/grafana:${var.grafana_tag}"
          image_pull_policy = "Always"
          name = "grafana"
          resources {
            limits {
              cpu    = "50m"
              memory = "50Mi"
            }
            requests {
              cpu    = "25m"
              memory = "50Mi"
            }
          }
          env {
            name = "GF_PATHS_DATA"
            value = "/opt/grafana/"
          }
          env {
            name = "GF_SERVER_HTTP_PORT"
            value = "3000"
          }
          env {
            name = "GF_SERVER_PROTOCOL"
            value = "http"
          }
          env {
            name = "GF_SERVER_DOMAIN"
            value = var.server_domain
          }
          env {
            name = "GF_SERVER_ROOT_URL"
            value = var.server_root_url
          }
          env {
            name = "GF_SREVER_ROUTER_LOGGING"
            value = "true"
          }
          env {
            name = "GF_DATABASE_TYPE"
            value = "sqlite3"
          }
          env {
            name = "GF_DATABASE_PATH"
            value = "/opt/grafana/grafana.db"
          }
          env {
            name = "GF_AUTH_BASIC_ENABLED"
            value = "false"
          }
          env {
            name = "GF_AUTH_DISABLE_LOGIN_FORM"
            value = "true"
          }
          env {
            name = "GF_AUTH_DISABLE_SIGNOUT_MENU"
            value = "true"
          }
          env {
            name = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }
          env {
            name = "GF_AUTH_ANONYMOUS_ORG_ROLE"
            value = "Admin"
          }
          env {
            name = "GF_USERS_ALLOW_SIGN_UP"
            value = "false"
          }
          env {
            name = "GF_USERS_ALLOW_ORG_CREATE"
            value = "false"
          }
          env {
            name = "GF_USERS_AUTO_ASSIGN_ORG"
            value = "true"
          }
          env {
            name = "GF_USERS_AUTO_ASSIGN_ORG_ROLE"
            value = "true"
          }
          env {
            name = "GF_LOG_MODE"
            value = "console"
          }
          env {
            name = "GF_LOG_LEVEL"
            value = "debug"
          }
          env {
            name = "GF_METRICS_ENABLED"
            value = "true"
          }
          env {
            name = "GF_ALERTING_ENABLED"
            value = "false"
          }
          env {
            name = "GF_SECURITY_ADMIN_USER"
            value_from {
              secret_key_ref {
                name = "grafana-secrets"
                key = "admin_user"
              }
            }
          }
          env {
            name = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = "grafana-secrets"
                key = "admin_password"
              }
            }
          }
          env {
            name = "GF_SECURITY_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = "grafana-secrets"
                key = "secret_key"
              }
            }
          }
          volume_mount {
            name = "grafana-data"
            mount_path = "/opt/grafana/"
          }
          port {
            container_port = 3000
            name = "http"
            protocol = "TCP"
          }
          security_context {
            run_as_user = 0 # TODO(adam): we need to lower/change this uid
            # From https://github.com/grafana/grafana/issues/13187
          }
        }
        volume {
          name = "grafana-data"
          persistent_volume_claim {
            claim_name = "grafana-data"
          }
        }
        volume {
          name = "nginx-conf"
          config_map {
            name = "grafana-nginx-config"
            items {
              key = "nginx.conf"
              path = "nginx.conf"
            }
            items {
              key = "default.conf"
              path = "conf.d/default.conf"
            }
          }
        }
        volume {
          name = "nginx-temp"
          empty_dir {}
        }
        volume {
          name = "nginx-www"
          config_map {
            name = "grafana-nginx-config"
            items {
              key = "metrics"
              path = "metrics"
            }
            items {
              key = "index.html"
              path = "index.html"
            }
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
