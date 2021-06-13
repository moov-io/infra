variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v2.1.0"
}

variable "addon_tag" {
  default = "1.8.4"
}
