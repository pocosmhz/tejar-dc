# Kube-Prometheus-Stack for onprem01 cluster
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "75.10.0"
  namespace  = kubernetes_namespace.prometheus.id
  values = [
    templatefile("${path.module}/source/helm/prometheus/kube-prometheus-stack-values.tpl.yml", {
      prom_conf = var.k8s_clusters["onprem01"].prometheus
    })
  ]
}