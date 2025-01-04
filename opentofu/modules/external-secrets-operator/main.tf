resource "helm_release" "external_secrets_operator" {
  name = "external-secrets-operator"
  repository = "https://charts.external-secrets.io"
  chart = "external-secrets"
  version = "0.12.1"
  namespace = var.external_secrets_operator_namespace
  create_namespace = true
  set {
    name = "bitwarden-sdk-server.enabled"
    value = var.enable_bitwarden_sdk_server
  }
}