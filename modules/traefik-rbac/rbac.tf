resource "kubernetes_cluster_role" "traefik" {
  metadata {
    name = "traefik"
  }
  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "traefik" {
  metadata {
    name = "terraform"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account
    namespace = var.service_account_namespace
  }
}
