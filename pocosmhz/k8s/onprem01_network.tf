# Networking components
# 1. kube-vip
# Traefik is defined in onprem01_traefik.tf.

resource "kubernetes_namespace" "kube_vip_system" {
  metadata {
    name = "kube-vip-system"
  }
}

resource "helm_release" "kube_vip" {
  name       = "kube-vip"
  repository = "https://kube-vip.github.io/helm-charts"
  chart      = "kube-vip"
  version    = "0.6.6"
  namespace  = kubernetes_namespace.kube_vip_system.id
  values = [
    templatefile("${path.module}/source/helm/kube-vip/kube-vip-values.tpl.yml", {
      kube_vip = var.k8s_clusters["onprem01"].kube_vip
    })
  ]
}
