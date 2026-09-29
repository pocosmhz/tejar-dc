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
  # 12.7.0 defaults to Gitea 1.27.0, which is affected by CVE-2026-60004.
  # The values file explicitly pins the patched 1.27.1 application image.
  version   = "12.7.0"
  namespace = kubernetes_namespace.gitea.id
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
