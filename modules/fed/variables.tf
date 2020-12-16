variable "docker_image" {
  default = "moov/fed:latest"
}

variable "namespace" {}

variable "instances" {
  default = 1
}

variable "log_format" {
  default = "plain"
}

variable "fedach_data_path" {
  default = ""
}

variable "fedwire_data_path" {
  default = ""
}

variable "fed_data_capacity" {
  default = 0
}
