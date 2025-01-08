variable "vault_helm_release_name" {
  description = "The name of the helm release for vault"
  type = string
  default = "vault"
}

variable "vault_namespace" {
  description = "The namespace to install vault into"
  type = string
  default = "vault"
}

variable "vault_version" {
  description = "The version of vault to install"
  type = string
}

variable "vault_values" {
  description = "The values to pass to the vault helm chart"
  type = list(string)
  default = <<EOF
server:
  # Use standalone mode for homelab - no need for HA
  standalone:
    enabled: true
    config: |
      ui = true
      
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      
      storage "file" {
        path = "/vault/data"
      }

  # Service configuration
  service:
    enabled: true
    type: ClusterIP

  # Basic resources suitable for homelab
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"

  # Enable the web UI
  ui:
    enabled: true
    serviceType: ClusterIP

# Disable injector for initial setup
injector:
  enabled: false

# Basic configuration for accessing Vault
global:
  tlsDisable: true

EOF
}

variable "vault_additional_values" {
  description = "Additional values to pass to the vault helm chart"
  type = map(string)
  # would look like this:
  # {
  #   "key1": "value1"
  #   "key2": "value2"
  # }
}