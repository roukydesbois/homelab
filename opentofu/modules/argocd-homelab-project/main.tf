resource "kubernetes_manifest" "app_project_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.app_project_namespace
    }
  }
}

data "kubernetes_config_map" "argocd_cmd_params_cm" {
  metadata {
    name = "argocd-cmd-params-cm"
    namespace = var.argocd_namespace
  }
}

resource "kubernetes_config_map_v1_data" "argocd_cmd_params_cm_update" {
  depends_on = [ kubernetes_manifest.app_project_namespace ]
  metadata {
    name = data.kubernetes_config_map.argocd_cmd_params_cm.metadata[0].name
    namespace = data.kubernetes_config_map.argocd_cmd_params_cm.metadata[0].namespace
  }
  data = {
    for key, value in data.kubernetes_config_map.argocd_cmd_params_cm.data : key => (
      key == "application.namespaces" ? join(",", tolist([value, var.app_project_namespace])) : value
    )
  }
  force = true
}

resource "null_resource" "restart_argocd_server" {
  depends_on = [ kubernetes_config_map_v1_data.argocd_cmd_params_cm_update ]
  provisioner "local-exec" {
    command = <<-EOT
      kubectl rollout restart deployment argocd-server -n ${var.argocd_namespace}
      kubectl rollout restart statefulset argocd-application-controller -n ${var.argocd_namespace}
    EOT
  }
}

resource "kubernetes_manifest" "app_project" {
  depends_on = [ kubernetes_manifest.app_project_namespace ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name = var.app_project_name
      namespace = var.argocd_namespace
    }
    spec = {
      destinations = [{
        namespace = var.app_project_namespace
        server = "https://kubernetes.default.svc"
      }]
      sourceRepos = var.app_project_source_repos
    }
  }
}

resource "kubernetes_manifest" "argocd_app_of_apps" {
  depends_on = [ kubernetes_manifest.app_project ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name = var.argocd_app_of_apps_name
      namespace = var.argocd_namespace
    }
    spec = {
      project = var.app_project_name
      source = yamldecode(var.app_of_apps_source_config_yaml)
      destination = {
        namespace = var.app_project_namespace
        server = "https://kubernetes.default.svc"
      }
      syncPolicy = {
        automated = {
          prune = true
          selfHeal = true
        }
      }
    }
  }
}