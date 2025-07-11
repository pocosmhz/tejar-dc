# Gitea SCM
resource "kubernetes_namespace" "gitea" {
  metadata {
    name = "gitea"
  }
}

resource "helm_release" "gitea" {
  name       = "gitea"
  repository = "https://dl.gitea.com/charts"
  chart      = "gitea"
  version    = "12.1.1"
  namespace  = kubernetes_namespace.gitea.id
  values = [
    templatefile("${path.module}/source/helm/gitea/gitea-values.tpl.yml", {
      gitea_conf = var.k8s_clusters["onprem01"].gitea
    })
  ]
  depends_on = [
    kubernetes_namespace.gitea,
    helm_release.cert_manager,
    helm_release.ceph_csi_rbd
  ]
}
