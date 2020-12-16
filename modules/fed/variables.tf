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

variable "fedach_data_filepath" {
  default = ""
}

variable "fedwire_data_filepath" {
  default = ""
}
