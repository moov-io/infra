resource "kubernetes_deployment" "customers" {
  metadata {
    name = "customers"
    namespace = var.namespace
    labels = {
      app = "customers"
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
        app = "customers"
      }
    }
    template {
      metadata {
        labels = {
          app = "customers"
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
          image = var.docker_image
          image_pull_policy = "Always"
          name  = "customers"
          args = [
            "-http.addr=:8080",
            "-admin.addr=:9090",
          ]
          env {
            name = "FED_ENDPOINT"
            value = var.fed_endpoint
          }
          env {
            name = "FED_DEBUG_CALLS"
            value = var.fed_debug_calls
          }
          env {
            name = "PAYGATE_ENDPOINT"
            value = var.paygate_endpoint
          }
          env {
            name = "PAYGATE_DEBUG_CALLS"
            value = var.paygate_debug_calls
          }
          env {
            name = "OFAC_MATCH_THRESHOLD"
            value = var.ofac_match_threshold
          }
          env {
            name = "WATCHMAN_ENDPOINT"
            value = var.watchman_endpoint
          }
          env {
            name = "WATCHMAN_DEBUG_CALLS"
            value = var.watchman_debug_calls
          }
          env {
            name = "DOCUMENTS_BUCKET_NAME"
            value = var.documents_bucket_name
          }
          env {
            name = "DOCUMENTS_STORAGE_PROVIDER"
            value = var.documents_storage_provider
          }
          env {
            name = "DOCUMENTS_SECRET_PROVIDER"
            value = var.documents_secret_provider
          }
          env {
            name = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/opt/moov/customers-documents/google-application-credentials"
          }
          env {
            name = "APP_SALT"
            value_from {
              secret_key_ref {
                name = "customers-secrets"
                key = "app-salt"
              }
            }
          }
          env {
            name = "REHASH_ACCOUNTS"
            value = var.rehash_accounts
          }
          env {
            name = "SECRETS_LOCAL_BASE64_KEY"
            value_from {
              secret_key_ref {
                name = "customers-secrets"
                key = "local-base64-key"
              }
            }
          }
          env {
            name = "TRANSIT_LOCAL_BASE64_KEY"
            value_from {
              secret_key_ref {
                name = "customers-transit-secrets"
                key = "transit-local-base64-key"
              }
            }
          }
          env {
            name = "LOG_FORMAT"
            value = "plain"
          }
          env {
            name = "DATABASE_TYPE"
            value = var.database_type
          }
          env {
            name = "SQLITE_DB_PATH"
            value = var.sqlite_db_path
          }
          env {
            name = "MYSQL_ADDRESS"
            value = var.mysql_address
          }
          env {
            name = "MYSQL_DATABASE"
            value = var.mysql_database
          }
          env {
            name = "MYSQL_USER"
            value = var.mysql_username
          }
          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = "customers-mysql-secrets"
                key = "password"
              }
            }
          }
          volume_mount {
            name = "customers"
            mount_path = "/opt/moov/customers/"
          }
          volume_mount {
            name = "customers-documents"
            mount_path = "/opt/moov/customers-documents/"
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
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          liveness_probe {
            http_get {
              path = "/live"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        volume {
          name = "customers"

          # With SQLite we can only have one instance so mount the PVC
          dynamic "persistent_volume_claim" {
            for_each = var.database_type == "sqlite" ? [1] : []
            content {
              claim_name = "customers"
            }
          }

          # For other databases just mount an empty dir since
          # there will be multiple instances.
          dynamic "empty_dir" {
            for_each = var.database_type != "sqlite" ? [1] : []
            content { }
          }
        }
        volume {
          name = "customers-documents"
          dynamic "secret" {
            for_each = var.google_application_credentials != "" ? [1] : []
            content {
              secret_name = "customers-secrets"
            }
          }
          dynamic "empty_dir" {
            for_each = var.google_application_credentials == "" ? [1] : []
            content { }
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
