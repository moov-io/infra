resource "kubernetes_config_map" "sftp-nginx-config" {
  metadata {
    name = "sftp-nginx-config"
    namespace = var.namespace
  }

  data = {
    "nginx.conf"   = file(var.nginx_config_filepath)
    "default.conf" = file(var.nginx_default_config_filepath)
    # stub response for prometheus metrics scraping
    "metrics"      = "# no content"
    "index.html"   = "nginx - grafana"
  }
}
