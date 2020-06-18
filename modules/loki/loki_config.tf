resource "kubernetes_config_map" "loki-config" {
  metadata {
    name = "loki-config"
    namespace = var.namespace
  }

  data = {
    "loki.yaml"   = "${file(var.loki_config_filepath)}"
  }
}
