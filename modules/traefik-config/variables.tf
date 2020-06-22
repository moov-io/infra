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
