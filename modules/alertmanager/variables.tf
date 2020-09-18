variable "namespace" {}

variable "instances" {
  default = 1
}

variable "alertmanager_tag" {
  default = "v0.20.0"
}

variable "capacity" {
  default = "10Gi"
}

variable "args" {
  type = list(string)
  default = [
    "--config.file=/opt/alertmanager/alertmanager.yaml",
    "--storage.path=/data/alertmanager/",
    "--web.listen-address=:9090",
    "--alerts.gc-interval=30m",
  ]
}

variable "additional_args" {
  type = list(string)
  default = []
}

variable "config_filepath" {}

variable "metrics_path" {
  default = "/metrics"
}
