resource "kubernetes_secret" "customers-transit-secrets" {
  metadata {
    name = "customers-transit-secrets"
    namespace = var.namespace
  }

  data = {
    "transit-local-base64-key" = "${file(var.transit_local_base64_key_filepath)}"
  }
}
