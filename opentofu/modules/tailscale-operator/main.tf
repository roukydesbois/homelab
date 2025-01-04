resource "helm_release" "tailscale_operator" {
    name       = var.tailscale_operator_helm_release_name
    repository = "https://pkgs.tailscale.com/helmcharts"
    chart      = "tailscale-operator"
    namespace  = var.tailscale_operator_namespace
    create_namespace = true
    version    = var.tailscale_operator_version
    
    set_sensitive {
        name  = "oauth.clientId"
        value = var.tailscale_oauth_client_id
    }
    
    set_sensitive {
        name  = "oauth.clientSecret"
        value = var.tailscale_oauth_client_secret
    }
    
    set {
        name  = "apiServerProxyConfig.mode"
        value = var.tailscale_operator_api_server_proxy_mode
        type = "string"
    }
    
    set {
        name  = "operatorConfig.hostname"
        value = var.tailscale_operator_hostname
    }
}