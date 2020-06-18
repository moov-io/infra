resource "kubernetes_cluster_role" "promtail" {
  metadata {
    name = "promtail"
  }
  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "promtail" {
  metadata {
    name = "promtail"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "promtail"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "promtail"
    namespace = var.namespace
  }
}
