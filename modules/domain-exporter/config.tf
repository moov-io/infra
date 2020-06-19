resource "kubernetes_config_map" "domain-exporter" {
  metadata {
    name = "domain-exporter"
    namespace = var.namespace
  }

  data = {
    "domains.yaml"   = "${file(var.config_filepath)}"
  }
}
