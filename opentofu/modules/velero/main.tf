resource "helm_release" "velero" {
  name = var.velero_helm_release_name
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart = "velero"
  namespace = var.velero_namespace
  create_namespace = true
  version = var.velero_version
  values = [ var.velero_values ]
}
