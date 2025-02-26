variable "sealed_secrets_helm_release_name" {
  type = string
  description = "Name of the sealed_secrets Helm release"
  default = "sealed-secrets"
}

variable "sealed_secrets_namespace" {
  type = string
  description = "Namespace to deploy sealed_secrets"
  default = "sealed-secrets"
}

variable "sealed_secrets_version" {
  type = string
  description = "Version of sealed secrets to deploy"
}

variable "sealed_secrets_values" {
  type = string
  description = "Values to pass to the sealed_secrets Helm chart"
  default = <<EOF
fullnameOverride: "sealed-secrets-controller"
EOF
}
