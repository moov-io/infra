locals {
  sftp_nginx_config_value = {
    "nginx.conf"   = file("${path.module}/conf/nginx.conf")
    "default.conf" = file("${path.module}/conf/default.conf")
    # stub response for prometheus metrics scraping
    "metrics"    = "# no content"
    "index.html" = "nginx - grafana"
  }
}

resource "random_id" "sftp_nginx_config_suffix" {
  keepers = {
    data = jsonencode(local.sftp_nginx_config_value)
  }

  byte_length = 8
}

resource "kubernetes_config_map" "sftp-nginx-config" {
  metadata {
    name      = "sftp-nginx-config-${random_id.sftp_nginx_config_suffix.hex}"
    namespace = var.namespace
  }

  data = local.sftp_nginx_config_value
}
