resource "helm_release" "sealed_secrets" {
  name = var.sealed_secrets_helm_release_name
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart = "sealed-secrets"
  namespace = var.sealed_secrets_namespace
  create_namespace = true
  version = var.sealed_secrets_version
  values = [ var.sealed_secrets_values ]
}
