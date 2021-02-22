variable "namespace" {}

variable "instances" {
  default = 1
}

variable "docker_image" {
  default = "gcr.io/cadvisor/cadvisor:v0.37.0"
}

## Default Resource Allocation
## Source: https://github.com/google/cadvisor/blob/v0.37.5/deploy/kubernetes/base/daemonset.yaml#L21-L27

variable "resources_limits_memory" {
  default = "2000Mi"
}
variable "resources_limits_cpu" {
  default = "300m"
}

variable "resources_requests_memory" {
  default = "200Mi"
}
variable "resources_requests_cpu" {
  default = "150m"
}
