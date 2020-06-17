variable "namespace" {}

variable "traefik_config_filepath" {
  description = "Filepath for YAML of Traefik config"
}

variable "nginx_config_filepath" {
  description = "Filepath for nginx config"
}

variable "nginx_default_config_filepath" {
  description = "Filepath for nginx default.conf"
}

variable "stage" {
  description = "Sub-Name of this traefik instance - e.g. alpha/beta"
}

variable "instances" {
  default = 1
}

variable "service_account_name" {
  default = "traefik"
}

variable "nginx_tag" {
  default = "1.19"
}

variable "nginx_exporter_tag" {
  default = "0.4.2"
}

variable "traefik_tag" {
  default = "v2.2"
}
