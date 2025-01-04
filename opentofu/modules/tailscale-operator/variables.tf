variable "tailscale_operator_helm_release_name" {
  type = string
  description = "Name of the Tailscale operator Helm release"
  default = "tailscale-operator"
}

variable "tailscale_operator_namespace" {
  type = string
  description = "Namespace to deploy the Tailscale operator"
  default = "tailscale-operator"
}

variable "tailscale_operator_version" {
  type = string
  description = "Version of the Tailscale operator to deploy"
  default = "v0.1.0"
}

variable "tailscale_oauth_client_id" {
  type = string
  description = "OAuth client ID for Tailscale"
}

variable "tailscale_oauth_client_secret" {
  type = string
  description = "OAuth client secret for Tailscale"
}

variable "tailscale_operator_api_server_proxy_mode" {
  type = string
  description = "Enable the API server proxy for the Tailscale operator"
  default = "false"
}

variable "tailscale_operator_hostname" {
  type = string
  description = "Hostname for the Tailscale operator"
}