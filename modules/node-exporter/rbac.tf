resource "kubernetes_cluster_role" "node-exporter" {
  metadata {
    name = "node-exporter"
  }
  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
    verbs      = ["create"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "delete", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "node-exporter" {
  metadata {
    name = "node-exporter"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "node-exporter"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "node-exporter"
    namespace = var.namespace
  }
}
