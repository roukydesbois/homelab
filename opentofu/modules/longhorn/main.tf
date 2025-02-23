resource "kubernetes_namespace" "longhorn_system" {
  count = var.overwrite_namespace_podsecuritypolicy ? 1 : 0

  metadata {
    name = "longhorn-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit" = "privileged"
      "pod-security.kubernetes.io/audit-version" = "latest"
      "pod-security.kubernetes.io/warn" = "privileged"
      "pod-security.kubernetes.io/warn-version" = "latest"
    }
  }
}

resource "helm_release" "longhorn" {
  name       = var.longhorn_helm_release_name
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = var.longhorn_version
  namespace  = var.longhorn_namespace
  create_namespace = true
}
