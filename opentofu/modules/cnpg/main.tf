resource "helm_release" "argocd" {
  name = var.cnpg_helm_release_name
  repository = "https://cloudnative-pg.github.io/charts"
  chart = "cloudnative-pg"
  namespace = var.cnpg_namespace
  create_namespace = true
  version = var.cnpg_version
}