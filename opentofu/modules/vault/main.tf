resource "helm_release" "vault" {
    name = var.vault_helm_release_name
    repository = "https://helm.releases.hashicorp.com"
    chart = "vault"
    namespace = var.vault_namespace
    create_namespace = true
    version = var.vault_version
    values = [ var.vault_values ]
}