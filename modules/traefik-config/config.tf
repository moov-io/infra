resource "kubernetes_config_map" "traefik-config" {
  metadata {
    name = "traefik-config"
    namespace = var.namespace
  }

  data = {
    "traefik.yaml" = "${file(var.traefik_config_filepath)}"
  }
}

resource "kubernetes_config_map" "traefik-nginx-config" {
  metadata {
    name = "traefik-nginx-config"
    namespace = var.namespace
  }

  data = {
    "nginx.conf"   = "${file(var.nginx_config_filepath)}"
    "default.conf" = "${file(var.nginx_default_config_filepath)}"
    # stub response for prometheus metrics scraping
    "metrics"      = "# no content"
    "index.html"   = "nginx - traefik"
  }
}
