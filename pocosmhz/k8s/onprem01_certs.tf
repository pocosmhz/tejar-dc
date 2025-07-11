# Certificate management
# 1. cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

data "http" "cert_manager_crds" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml"
}

# The following brilliant solution was taken from:
# https://github.com/hashicorp/terraform/issues/29729#issuecomment-2138367809

locals {
  cert_manager_crds = provider::kubernetes::manifest_decode_multi(data.http.cert_manager_crds.response_body)
}

resource "kubernetes_manifest" "cert_manager_crds" {
  for_each = {
    for manifest in local.cert_manager_crds :
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }
  manifest = each.value
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.18.2"
  namespace  = kubernetes_namespace.cert_manager.id
  values = [
    templatefile("${path.module}/source/helm/cert-manager/cert-manager-values.tpl.yml", {
      namespace          = kubernetes_namespace.cert_manager.id
      prometheus_enabled = false # Set to true if you want to enable Prometheus monitoring and have fixed the errors ... ;-)
    })
  ]
  depends_on = [kubernetes_manifest.cert_manager_crds]
}

resource "kubernetes_manifest" "cluster_issuer_letsencrypt" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        server = var.k8s_clusters["onprem01"].cert_manager.acme.server
        email  = var.k8s_clusters["onprem01"].cert_manager.acme.email
        privateKeySecretRef = {
          name = "letsencrypt-account-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = var.k8s_clusters["onprem01"].cert_manager.ingress_class
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [helm_release.cert_manager]
}
