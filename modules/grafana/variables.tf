variable "namespace" {}

variable "instances" {
  default = 1
}

variable "grafana_tag" {
  default = "7.5.7"
}

variable "nginx_tag" {
  default = "1.19"
}

variable "nginx_exporter_tag" {
  default = "0.4.2"
}

variable "capacity" {
  default = "1Gi"
}

variable "nginx_config_filepath" {}
variable "nginx_default_config_filepath" {}

variable "server_domain" {}
variable "server_root_url" {}

variable "admin_user_filepath" {}
variable "admin_password_filepath" {}
variable "secret_key_filepath" {}

variable "install_plugins" {
  default = []
}

variable "resources_cpu_limit" {
  default = "1000m"
}

variable "resources_mem_limit" {
  default = "1024Mi"
}

variable "resources_cpu_request" {
  default = "100m"
}

variable "resources_mem_request" {
  default = "256Mi"
}
