resource "helm_release" "longhorn" {
  name       = var.longhorn_helm_release_name
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = var.longhorn_version
  namespace  = var.longhorn_namespace
  create_namespace = true
}
