resource "kubernetes_config_map" "promtail-config" {
  metadata {
    name = "promtail-config"
    namespace = var.namespace
  }

  data = {
    "promtail.yaml"   = "${file(var.promtail_config_filepath)}"
  }
}
