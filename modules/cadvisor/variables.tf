variable "namespace" {}

variable "instances" {
  default = 1
}

variable "docker_image" {
  default = "gcr.io/cadvisor/cadvisor:v0.37.0"
}
