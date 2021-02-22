variable "docker_image" {
  default = "moov/customers:latest"
}

variable "namespace" {}

variable "instances" {
  default = 1
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

variable "app_salt_filepath" {
  default = ""
}

variable "rehash_accounts" {
  default = "false"
}

variable "tumbler_host" {
  default = ""
}

variable "kafka_brokers" {
  default = ""
}

variable "kafka_changes_producer" {
  default = ""
}

variable "kafka_commands_producer" {
  default = ""
}

# Both values are URIs generated with ./cmd/genkey from https://github.com/moov-io/customers
# More Details: https://moov-io.github.io/customers/configuration.html#account-numbers
variable "local_base64_key_filepath" {}
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

## Document Storage
variable "documents_bucket_name" {
  default = ""
}
variable "documents_storage_provider" {
  default = ""
}
variable "documents_secret_provider" {
  default = ""
}

variable "google_application_credentials" {
  default = "missing.json"
}

variable "resources_cpu_limit" {
  default = "1000m"
}

variable "resources_mem_limit" {
  default = "1024Mi"
}

variable "resources_cpu_request" {
  default = "100m"
}

variable "resources_mem_request" {
  default = "256Mi"
}
