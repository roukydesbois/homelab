variable "argocd_helm_release_name" {
  type = string
  description = "Name of the ArgoCD Helm release"
  default = "argocd"
}

variable "argocd_namespace" {
  type = string
  description = "Namespace to deploy ArgoCD"
  default = "argocd"  
}

variable "argocd_version" {
  type = string
  description = "Version of ArgoCD to deploy"
}

variable "argocd_values" {
  type = string
  description = "Values to pass to the ArgoCD Helm chart"
}