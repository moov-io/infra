resource "kubernetes_config_map" "sftp-nginx-config" {
  metadata {
    name = "sftp-nginx-config"
    namespace = var.namespace
  }

  data = {
    "nginx.conf"   = file("${path.module}/conf/nginx.conf")
    "default.conf" = file("${path.module}/conf/default.conf")
    # stub response for prometheus metrics scraping
    "metrics"      = "# no content"
    "index.html"   = "nginx - grafana"
  }
}
