resource "kubernetes_secret" "alertmanager-config" {
  metadata {
    name = "alertmanager-config"
    namespace = var.namespace
  }

  data = {
    "alertmanager.yaml" = "${trimspace(file(var.config_filepath))}"
  }
}
