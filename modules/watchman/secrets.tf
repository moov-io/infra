locals {
  pass = "${fileexists(var.mysql_password_filename) ? file(var.mysql_password_filename) : ""}"
}

resource "kubernetes_secret" "watchman-mysql" {
  metadata {
    name = "watchman-mysql"
    namespace = var.namespace
  }
  data = {
    "password" = "${trimspace(local.pass)}"
  }
}
