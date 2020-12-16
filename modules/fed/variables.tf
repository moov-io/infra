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
