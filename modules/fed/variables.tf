variable "docker_image" {
  default = "moov/fed:latest"
}

variable "namespace" {}

variable "instances" {
  default = 1
}

variable "args" {
  default = [
    "-http.addr=:8080",
    "-admin.addr=:9090",
  ]
}

variable "log_format" {
  default = "plain"
}

variable "fedach_data_path" {
  default = "/data/fed/FedACHdir.txt"
}

variable "fedwire_data_path" {
  default = "/data/fed/fpddir.txt"
}

variable "fed_data_capacity" {
  default = 0
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
