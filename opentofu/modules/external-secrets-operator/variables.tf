variable "external_secrets_operator_namespace" {
  type = string
  description = "Namespace to deploy the External Secrets operator"
  default = "external-secrets"
}

variable "enable_bitwarden_sdk_server" {
  type = bool
  description = "Enable the Bitwarden SDK server"
  default = false
}