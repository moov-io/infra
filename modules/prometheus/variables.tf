variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v2.19.2"
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

variable "additional_args" {
  type = list(string)
  default = []
}

variable "resources_memory_limit" {
  default = "3000Mi"
}
variable "resources_memory_request" {
  default = "2000Mi"
}
