variable "namespace" {}

variable "loki_instances" {
  default = 1
}
variable "loki_tag" {
  default = "2.2.0"
}
variable "loki_config_filepath" {}
variable "loki_storage_capacity" {
  default = "100Gi"
}
variable "base_path" {
  default = "/loki/"
}
variable "loki_args" {
  type = list(string)
  default = [
    "-config.file=/etc/loki/loki.yaml",
    "-log.level=info",
  ]
}


variable "promtail_tag" {
  default = "2.2.0"
}
variable "promtail_config_filepath" {}
variable "promtail_args" {
  type = list(string)
  default = [
    "-config.file=/etc/promtail/promtail.yaml",
  ]
}
