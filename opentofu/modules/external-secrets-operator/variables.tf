variable "external_secrets_helm_release_name" {
  type = string
  description = "Name of the External Secrets operator Helm release"
  default = "external-secrets"
}

variable "external_secrets_operator_version" {
  type = string
  description = "Version of the External Secrets operator to deploy"
}

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