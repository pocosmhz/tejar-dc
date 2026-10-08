resource "kubernetes_namespace_v1" "ceph_csi_rbd" {
  metadata {
    name = "ceph-csi-rbd"
  }
}

resource "helm_release" "ceph_csi_rbd" {
  name       = "ceph-csi-rbd"
  repository = "https://ceph.github.io/csi-charts"
  chart      = "ceph-csi-rbd"
  version    = "3.16.3"
  namespace  = kubernetes_namespace_v1.ceph_csi_rbd.metadata[0].name
  timeout    = 1200
  postrender = {
    binary_path = "python3"
    args        = [abspath("${path.module}/scripts/preserve-ceph-rbd-storageclass.py")]
  }
  values = [
    templatefile("${path.module}/source/helm/ceph/ceph-csi-rbd-values.tpl.yml", {
      ceph_conf = var.k8s_clusters["onprem01"].ceph
    })
  ]
}
