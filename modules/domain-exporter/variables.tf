variable "namespace" {}

variable "instances" {
  default = 1
}

variable "config_filepath" {}

variable "image_tag" {
  default = "v0.1.8-go1.11.4"
}

variable "resources_cpu_limit" {
  default = "1000m"
}

variable "resources_mem_limit" {
  default = "256Mi"
}

variable "resources_cpu_request" {
  default = "100m"
}

variable "resources_mem_request" {
  default = "128Mi"
}
