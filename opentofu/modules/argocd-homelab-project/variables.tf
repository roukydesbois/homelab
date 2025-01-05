variable "argocd_namespace" {
  description = "The namespace ArgoCD is deployed in"
  type        = string
  default = "argocd"
}

variable "app_project_name" {
  description = "The name of the ArgoCD project"
  type        = string
}

variable "app_project_namespace" {
  description = "The namespace to deploy the ArgoCD project in"
  type        = string
}

variable "app_project_source_repos" {
  description = "The source repositories to sync with the ArgoCD project"
  type        = list(string)
}

variable "app_of_apps_source_config_yaml" {
  description = "The configuration for the App of Apps ArgoCD source parameter in yaml format"
  type        = string
}