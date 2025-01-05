resource "kubernetes_manifest" "app_project_namespace" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.app_project_namespace
    }
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