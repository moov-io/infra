resource "kubernetes_secret" "github-exporter" {
  metadata {
    name = "github-exporter"
    namespace = var.namespace
  }

  data = {
    "github-token" = "${trimspace(file(var.github_token_filepath))}"
  }
}
