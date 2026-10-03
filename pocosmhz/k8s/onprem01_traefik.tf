# Helm installs Traefik's CRDs before these extraObjects. Keeping custom
# resources in the release avoids OpenTofu's plan-time CRD discovery problem.
resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "41.6.1"
  namespace  = kubernetes_namespace.traefik.id

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    templatefile("${path.module}/source/helm/traefik/traefik-values.tpl.yml", {
      traefik_conf = var.k8s_clusters["onprem01"].traefik
      irc_conf     = var.k8s_clusters["onprem01"].irc
    }),
    yamlencode({
      extraObjects = [
        {
          apiVersion = "traefik.io/v1alpha1"
          kind       = "IngressRouteTCP"
          metadata = {
            name      = "ergo"
            namespace = kubernetes_namespace.irc.id
          }
          spec = {
            ingressClassName = "traefik"
            entryPoints      = ["ircs"]
            routes = [{
              # Catch all connections, including IRC clients without SNI.
              match    = "HostSNI(`*`)"
              services = [{ name = "ergo", port = 6697 }]
            }]
            tls = { passthrough = true }
          }
        },
        {
          apiVersion = "traefik.io/v1alpha1"
          kind       = "Middleware"
          metadata = {
            name      = "upload-limit"
            namespace = kubernetes_namespace.forgejo.id
          }
          spec = {
            buffering = {
              maxRequestBodyBytes = 1073741824
              memRequestBodyBytes = 1048576
            }
          }
        }
      ]
    })
  ]
  depends_on = [helm_release.kube_vip]
}
