variable "nginx_image" {
  default = "nginx:1.19"
}
variable "sftp_image" {
  default = "atmoz/sftp:latest"
}

variable "namespace" {}

variable "instances" {
  default = 0
}

variable "nginx_config_filepath" {}
variable "nginx_default_config_filepath" {}
