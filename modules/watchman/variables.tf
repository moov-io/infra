variable "tag" {
  default = "latest"
}

variable "namespace" {}

variable "resources_cpu_request" {
  default = "25m"
}
variable "resources_mem_request" {
  default = "25Mi"
}
variable "resources_mem_limit" {
  default = "100Mi"
}
