variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v1.9.8"
}

variable "addon_tag" {
  default = "1.8.4"
}
