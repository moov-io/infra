resource "kubernetes_service" "sftp" {
  metadata {
    name      = "sftp"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "sftp"
    }
    port {
      name        = "sftp"
      port        = 22
      target_port = 22
      protocol    = "TCP"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}
