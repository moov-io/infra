variable "namespace" {}

variable "loki_instances" {
  default = 1
}
variable "loki_tag" {
  default = "1.5.0"
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
    "-config.file=/etc/loki/loki.yml",
    "-log.level=info",
  ]
}


variable "promtail_tag" {
  default = "1.5.0"
}
variable "promtail_config_filepath" {}
variable "promtail_args" {
  type = list(string)
  default = [
    "-config.file=/etc/promtail/promtail.yml",
  ]
}
# -client.url=http://loki.infra.svc.cluster.local:3100/loki/api/prom/push # TOOD(adam): HTTPS
