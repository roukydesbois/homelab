resource "helm_release" "cnpg" {
  name = var.cnpg_helm_release_name
  repository = "https://cloudnative-pg.github.io/charts"
  chart = "cloudnative-pg"
  namespace = var.cnpg_namespace
  create_namespace = true
  version = var.cnpg_version
}

resource "kubernetes_manifest" "postgis_cluster_imagecatalog" {
  manifest = yamldecode(templatefile("${path.module}/manifests/postgis-cluster-imagecatalog.yaml", {
    cnpg_namespace = var.cnpg_namespace
  }))
}
