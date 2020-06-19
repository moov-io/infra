variable "namespace" {}

variable "instances" {
  default = 1
}

variable "config_filepath" {}

variable "image_tag" {
  default = "v0.1.8-go1.11.4"
}
