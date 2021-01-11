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
