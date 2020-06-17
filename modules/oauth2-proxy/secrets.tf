resource "kubernetes_secret" "oauth2-proxy-config" {
  metadata {
    name = "oauth2-proxy-config"
    namespace = var.namespace
  }

  data = {
    "client_id" = "${trimspace(file(var.client_id_filepath))}"
    "client_secret" = "${trimspace(file(var.client_secret_filepath))}"
    "cookie_secret" = "${base64decode(trimspace(file(var.cookie_secret_filepath)))}"
  }
}
