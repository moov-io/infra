resource "kubernetes_secret" "watchman-mysql" {
  metadata {
    name = "watchman-mysql"
    namespace = var.namespace
  }
  data = {
    "password" = "${trimspace(file(var.mysql_password_filename))}"
  }
}
