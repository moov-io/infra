variable "tag" {
  default = "latest"
}

variable "namespace" {}

variable "instances" {
  default = 1
}

variable "fed_endpoint" {
  default = "http://fed.apps.svc.cluster.local:8080"
}

variable "paygate_endpoint" {
  default = "http://paygate.apps.svc.cluster.local:8080"
}

variable "watchman_endpoint" {
  default = "http://watchman.apps.svc.cluster.local:8080"
}

variable "capacity" {
  default = "1Gi"
}

variable "transit_local_base64_key_filepath" {}
