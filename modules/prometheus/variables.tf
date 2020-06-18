variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v2.18.1"
}

variable "config_filepath" {}
variable "rules_filepath" {}

variable "storage_capacity" {
  default = "50Gi"
}

variable "base_path" {
  default = "/prometheus/"
}

variable "args" {
  type = list(string)
  default = [
    "--config.file=/opt/prometheus/prometheus.yaml",
    "--storage.tsdb.path=/data/prometheus",
    "--web.console.libraries=/usr/share/prometheus/console_libraries",
    "--web.console.templates=/usr/share/prometheus/consoles",
  ]
}
# --web.enable-lifecycle # TODO(adam): kubectl port-forward doesn't work to curl -XPOST /-/reload

# "--storage.tsdb.retention.time=168h", # 7 * 24hours
# "--web.external-url=https://infra-oss.moov.io/prometheus/",
