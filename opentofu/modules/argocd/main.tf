resource "helm_release" "argocd" {
  name = var.argocd_helm_release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  namespace = var.argocd_namespace
  create_namespace = true
  version = var.argocd_version
  values = [ var.argocd_values ]
}