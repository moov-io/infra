locals {
  traefik_config_value = {
    "traefik.yaml" = file(var.traefik_config_filepath)
  }
  traefik_nginx_config_value = {
    "nginx.conf"   = file(var.nginx_config_filepath)
    "default.conf" = file(var.nginx_default_config_filepath)
    # stub response for prometheus metrics scraping
    "metrics"    = "# no content"
    "index.html" = "nginx - traefik"
  }
}

resource "random_id" "traefik_config_suffix" {
  keepers = {
    data = jsonencode(local.traefik_config_value)
  }

  byte_length = 8
}

resource "random_id" "traefik_nginx_config_suffix" {
  keepers = {
    data = jsonencode(local.traefik_nginx_config_value)
  }

  byte_length = 8
}

resource "kubernetes_config_map" "traefik-config" {
  metadata {
    name      = "traefik-${var.stage}-config-${random_id.traefik_config_suffix.hex}"
    namespace = var.namespace
  }

  data = local.traefik_config_value
}

resource "kubernetes_config_map" "traefik-nginx-config" {
  metadata {
    name      = "traefik-${var.stage}-nginx-config-${random_id.traefik_nginx_config_suffix.hex}"
    namespace = var.namespace
  }

  data = local.traefik_nginx_config_value
}
