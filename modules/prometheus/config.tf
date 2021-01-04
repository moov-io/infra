resource "kubernetes_config_map" "prometheus-config" {
  metadata {
    name = "prometheus-config"
    namespace = var.namespace
  }

  data = {
    "prometheus.yaml" = file(var.config_filepath)
  }
}

resource "kubernetes_config_map" "prometheus-rules" {
  metadata {
    name = "prometheus-rules"
    namespace = var.namespace
  }

  data = {
    "rules.yaml" = file(var.rules_filepath)
  }
}
