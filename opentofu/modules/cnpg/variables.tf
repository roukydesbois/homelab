variable "cnpg_helm_release_name" {
  type = string
  description = "Name of the CNPG Helm release"
  default = "cnpg"
}

variable "cnpg_namespace" {
  type = string
  description = "Namespace to deploy CNPG"
  default = "cnpg-system"  
}

variable "cnpg_version" {
  type = string
  description = "Version of CNPG to deploy"
}