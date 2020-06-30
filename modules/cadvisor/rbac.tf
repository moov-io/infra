resource "kubernetes_cluster_role" "cadvisor" {
  metadata {
    labels = {
      app = "cadvisor"
    }
    name = "cadvisor"
  }
  rule {
    api_groups     = ["policy"]
    resource_names = ["cadvisor"]
    resources      = ["podsecuritypolicy"]
    verbs          = ["use"]
  }
}

resource "kubernetes_cluster_role_binding" "cadvisor" {
  metadata {
    labels = {
      app = "cadvisor"
    }
    name = "cadvisor"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cadvisor"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cadvisor"
    namespace = var.namespace
  }
}
