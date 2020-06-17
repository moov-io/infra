variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v5.1.1"
}

variable "client_id_filepath" {}
variable "client_secret_filepath" {}
variable "cookie_secret_filepath" {}

variable "container_arguments" {
  type = list(string)
  default = []
}
