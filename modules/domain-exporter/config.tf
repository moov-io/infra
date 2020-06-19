resource "kubernetes_config_map" "domain-exporter-config" {
  metadata {
    name = "domain-exporter-config"
    namespace = var.namespace
  }

  data = {
    "domains.yaml"   = "${file(var.config_filepath)}"
  }
}
