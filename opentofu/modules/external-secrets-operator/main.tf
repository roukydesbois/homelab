resource "helm_release" "external_secrets_operator" {
  name = var.external_secrets_helm_release_name
  repository = "https://charts.external-secrets.io"
  chart = "external-secrets"
  version = var.external_secrets_operator_version
  namespace = var.external_secrets_operator_namespace
  create_namespace = true
  set {
    name = "bitwarden-sdk-server.enabled"
    value = var.enable_bitwarden_sdk_server
  }
}