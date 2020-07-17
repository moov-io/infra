resource "kubernetes_secret" "customers-transit-secrets" {
  metadata {
    name = "customers-transit-secrets"
    namespace = var.namespace
  }

  data = {
    "transit-local-base64-key" = "${trimspace(file(var.transit_local_base64_key_filepath))}"
  }
}

resource "kubernetes_secret" "customers-mysql-secrets" {
  metadata {
    name = "customers-mysql-secrets"
    namespace = var.namespace
  }

  data = {
    "password" = "${fileexists(var.mysql_password_filepath) ? trimspace(file(var.mysql_password_filepath)) : ""}"
  }
}
