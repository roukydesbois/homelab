resource "helm_release" "cert_manager" {
  name       = var.cert_manager_helm_release_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
  namespace  = var.cert_manager_namespace
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}