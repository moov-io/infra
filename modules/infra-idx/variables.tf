variable "namespace" {}

variable "instances" {
  default = 2
}

variable "nginx_exporter_tag" {
  default = "0.4.2"
}

variable "infra_idx_tag" {
  default = "v0.2.1"
}
