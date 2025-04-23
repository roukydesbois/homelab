variable "velero_helm_release_name" {
  type = string
  description = "Name of the velero Helm release"
  default = "velero"
}

variable "velero_namespace" {
  type = string
  description = "Namespace to deploy velero"
  default = "velero"
}

variable "velero_version" {
  type = string
  description = "Version of the velero Helm chart to deploy"
}

variable "velero_values" {
  type = string
  description = "Values to pass to the velero Helm chart"
  default = <<EOF
EOF
}
