variable "longhorn_helm_release_name" {
  type = string
  description = "Name of the longhorn Helm release"
  default = "longhorn"
}

variable "longhorn_namespace" {
  type = string
  description = "Namespace to deploy Longhorn"
  default = "longhorn-system"
}

variable "longhorn_version" {
  type = string
  description = "Version of Longhorn to deploy"
}

variable "overwrite_namespace_podsecuritypolicy" {
  type = bool
  description = "Overwrite the namespace pod security policy"
  default = false
}
