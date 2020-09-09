resource "kubernetes_cluster_role" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
    labels = {
      "app.kubernetes.io/name" = "kube-state-metrics"
      "app.kubernetes.io/version" = "v1.9.2"
    }
  }
  rule {
    api_groups = [""]
    resources  = [
      "configmaps",
      "secrets",
      "nodes",
      "pods",
      "services",
      "resourcequotas",
      "replicationcontrollers",
      "limitranges",
      "persistentvolumeclaims",
      "persistentvolumes",
      "namespaces",
      "endpoints",
    ]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = [
      "daemonsets",
      "deployments",
      "replicasets",
      "ingresses",
    ]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = [
      "statefulsets",
      "daemonsets",
      "deployments",
      "replicasets",
    ]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = [
      "cronjobs",
      "jobs"
    ]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "volumeattachments"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kube-state-metrics" {
  metadata {
    name = "kube-state-metrics"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kube-state-metrics"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kube-state-metrics"
    namespace = var.namespace
  }
}
