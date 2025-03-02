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

variable "argocd_app_of_apps_name" {
  description = "The name of the App of Apps ArgoCD application"
  type        = string
}

variable "app_of_apps_source_config_yaml" {
  description = "The configuration for the App of Apps ArgoCD source parameter in yaml format"
  type        = string
}

variable "kube_config" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "cluster_resource_whitelist" {
  description = "The cluster resources to whitelist in the ArgoCD project"
  type        = list(object({
    group = string
    kind  = string
  }))
  default =  []
}

variable "namespace_resource_whitelist" {
  description = "The namespace resources to whitelist in the ArgoCD project"
  type        = list(object({
    group = string
    kind  = string
  }))
  default =  []
}
