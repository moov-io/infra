variable "tag" {
  default = "latest"
}

variable "namespace" {}

variable "instances" {
  default = 1
}

variable "namespace_header" {
  default = ""
}

variable "fed_endpoint" {
  default = "http://fed.apps.svc.cluster.local:8080"
}

variable "fed_debug_calls" {
  default = "false"
}

variable "paygate_endpoint" {
  default = "http://paygate.apps.svc.cluster.local:8080"
}

variable "paygate_debug_calls" {
  default = "false"
}

variable "ofac_match_threshold" {
  default = "0.99"
}

variable "watchman_endpoint" {
  default = "http://watchman.apps.svc.cluster.local:8080"
}

variable "watchman_debug_calls" {
  default = "false"
}

variable "capacity" {
  default = "1Gi"
}

variable "accounts_local_base64_key_filepath" {}
variable "transit_local_base64_key_filepath" {}

variable "database_type" {
  default = "sqlite"
}

variable "sqlite_db_path" {
  default = "/opt/moov/customers/customers.db"
}

variable "mysql_address" {
  default = "tcp(mysql:3306)"
}
variable "mysql_database" {
  default = "customers"
}
variable "mysql_username" {
  default = "customers"
}
variable "mysql_password_filepath" {}
