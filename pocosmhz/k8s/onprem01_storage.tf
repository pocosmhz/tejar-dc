resource "kubernetes_namespace" "ceph_csi_rbd" {
  metadata {
    name = "ceph-csi-rbd"
  }
}

resource "helm_release" "ceph_csi_rbd" {
  name       = "ceph-csi-rbd"
  repository = "https://ceph.github.io/csi-charts"
  chart      = "ceph-csi-rbd"
  version    = "3.14.1"

  namespace = kubernetes_namespace.ceph_csi_rbd.metadata[0].name

}
