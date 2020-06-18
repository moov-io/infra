resource "kubernetes_service_account" "promtail" {
  metadata {
    name = "promtail"
    namespace = var.namespace
  }
}
