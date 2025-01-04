variable "cert_manager_helm_release_name" {
  type = string
  description = "Name of the Cert Manager Helm release"
  default = "cert-manager"
}

variable "cert_manager_namespace" {
  type = string
  description = "Namespace to deploy Cert Manager"
  default = "cert-manager"  
}

variable "cert_manager_version" {
  type = string
  description = "Version of Cert Manager to deploy"
}