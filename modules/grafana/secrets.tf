resource "kubernetes_secret" "grafana-secrets" {
  metadata {
    name = "grafana-secrets"
    namespace = var.namespace
  }

  data = {
    "admin_user" = trimspace(file(var.admin_user_filepath))
    "admin_password" = trimspace(file(var.admin_password_filepath))
    "secret_key" = trimspace(file(var.secret_key_filepath))
  }
}
