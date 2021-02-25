variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v1.1.1"
}

## Default Resource Allocation
## Source: https://github.com/openstack/openstack-helm-infra/blob/1f5e3ad8c76ba158217631b85caf92e1e2b17de4/prometheus-node-exporter/values.yaml#L72

variable "resources_limits_memory" {
  default = "1024Mi"
}
variable "resources_limits_cpu" {
  default = "2000m"
}

variable "resources_requests_memory" {
  default = "128Mi"
}
variable "resources_requests_cpu" {
  default = "100m"
}
