variable "namespace" {}

variable "instances" {
  default = 1
}

variable "image_tag" {
  default = "v6.0.0"
}

variable "client_id_filepath" {}
variable "client_secret_filepath" {}
variable "cookie_secret_filepath" {
  description = "Base64 encoded string of HTTP cookie secret. Check oauth2-proxy docs or a script to generate this value"
}

variable "container_arguments" {
  type = list(string)
  default = []
}
