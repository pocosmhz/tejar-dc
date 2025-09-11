# Opensearch configuration for Kubernetes on-premises
resource "kubernetes_namespace" "opensearch" {
  metadata {
    name = "opensearch"
  }
}

# This is needed by the following services:
# - OpenSearch : Thanks to https://eliatra.com/blog/opensearch-with-cert-manager-part-2-self-signed-ca/
resource "kubernetes_manifest" "os_issuer_self_signed" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "opensearch-selfsigned"
      namespace = kubernetes_namespace.opensearch.id
    }
    spec = {
      selfSigned = {}
    }
  }
  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "os_certificate_ca_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "opensearch-ca-cert"
      namespace = kubernetes_namespace.opensearch.id
    }
    spec = {
      isCA        = true
      duration    = "43800h" # 5 years
      renewBefore = "360h"   # 15 days
      commonName  = "*.${var.k8s_clusters["onprem01"].opensearch.ca_common_name}"
      secretName  = "ca-cert-key"
      privateKey = {
        algorithm = "RSA"
        size      = 4096
        encoding  = "PKCS8"
      }
      issuerRef = {
        name = kubernetes_manifest.os_issuer_self_signed.object.metadata.name
        kind = kubernetes_manifest.os_issuer_self_signed.object.kind
      }
    }
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_manifest.os_issuer_self_signed
  ]
}

resource "kubernetes_manifest" "opensearch_issuer_ca" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "opensearch-issuer-from-ca"
      namespace = kubernetes_namespace.opensearch.id
    }
    spec = {
      ca = {
        secretName = kubernetes_manifest.os_certificate_ca_cert.object.spec.secretName # this is the previously created secret
      }
    }
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_manifest.os_certificate_ca_cert
  ]
}

resource "kubernetes_manifest" "opensearch_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "opensearch-tls"
      namespace = kubernetes_namespace.opensearch.id
    }
    spec = {
      isCA        = false
      duration    = "2160h" # 90 days
      renewBefore = "360h"  # 15 days
      commonName  = "opensearch.${var.k8s_clusters["onprem01"].opensearch.ca_common_name}"
      dnsNames = [
        "opensearch.${var.k8s_clusters["onprem01"].opensearch.ca_common_name}"
      ]
      secretName = var.k8s_clusters["onprem01"].opensearch.tls_secret_name
      privateKey = {
        algorithm = "RSA"
        encoding  = "PKCS8"
        size      = 2048
      }
      usages = [
        "server auth",
        "client auth"
      ]
      issuerRef = {
        name  = kubernetes_manifest.opensearch_issuer_ca.object.metadata.name
        kind  = kubernetes_manifest.opensearch_issuer_ca.object.kind
        group = "cert-manager.io"
      }
    }
  }
}

resource "helm_release" "opensearch_operator" {
  name       = "opensearch"
  repository = "https://opensearch-project.github.io/opensearch-k8s-operator"
  chart      = "opensearch-operator"
  version    = "2.8.0"
  namespace  = kubernetes_namespace.opensearch.id
  values = [
    templatefile("${path.module}/source/helm/opensearch/opensearch-operator-values.tpl.yml", {
      opensearch_conf = var.k8s_clusters["onprem01"].opensearch
    })
  ]
}

resource "kubernetes_secret" "admincredentials_secret" {
  metadata {
    name      = "admin-credentials-secret"
    namespace = kubernetes_namespace.opensearch.id
  }
  data = {
    "username" = "admin"
    "password" = "admin" # base64encode(var.k8s_clusters["onprem01"].opensearch.initial_admin_password)
  }
  type       = "Opaque"
  depends_on = [helm_release.opensearch_operator]
}

resource "kubernetes_secret" "securityconfig_secret" {
  metadata {
    name      = "securityconfig-secret"
    namespace = kubernetes_namespace.opensearch.id
  }
  data = {
    "internal_users.yml" = templatefile("${path.module}/source/helm/opensearch/internal_users.tpl.yml", {
      initial_admin_password = var.k8s_clusters["onprem01"].opensearch.initial_admin_password
    })
    "action_groups.yml" = file("${path.module}/source/helm/opensearch/action_groups.tpl.yml")
    "roles_mapping.yml" = file("${path.module}/source/helm/opensearch/roles_mapping.tpl.yml")
    "roles.yml"         = file("${path.module}/source/helm/opensearch/roles.tpl.yml")
    "config.yml"        = file("${path.module}/source/helm/opensearch/config.tpl.yml")
  }
  type       = "Opaque"
  depends_on = [helm_release.opensearch_operator]
}

resource "kubernetes_manifest" "opensearch_cluster" {
  for_each = var.k8s_clusters["onprem01"].opensearch.clusters
  manifest = {
    apiVersion = "opensearch.opster.io/v1"
    kind       = "OpenSearchCluster"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.opensearch.id
    }
    spec = {
      general = {
        serviceName      = each.key
        version          = each.value.version != null ? each.value.version : "2.10.0"
        setVMMaxMapCount = true # This is required for OpenSearch not to complain about the VM max map count
      }
      security = {
        config = {
          adminCredentialsSecret = {
            name = kubernetes_secret.admincredentials_secret.metadata[0].name
          }
          securityConfigSecret = {
            name = kubernetes_secret.securityconfig_secret.metadata[0].name
          }
        }
        tls = {
          transport = {
            generate = each.value.security.tls.transport.generate
            perNode  = each.value.security.tls.transport.per_node
            secret = {
              name = var.k8s_clusters["onprem01"].opensearch.tls_secret_name
            }
            caSecret = (var.k8s_clusters["onprem01"].opensearch.ca_secret_name != null &&
              var.k8s_clusters["onprem01"].opensearch.ca_secret_name != "") ? {
              name = var.k8s_clusters["onprem01"].opensearch.ca_secret_name
            } : null
            nodesDn = each.value.security.tls.transport.nodes_dn != null ? each.value.security.tls.transport.nodes_dn : []
          }
        }
      }
      dashboards = {
        enable    = each.value.dashboards.enable
        version   = each.value.version != null ? each.value.version : "2.10.0"
        replicas  = 1
        resources = each.value.dashboards.resources
      }
      nodePools = [
        for pool in each.value.node_pools : {
          component = pool.component
          replicas  = pool.replicas
          diskSize  = pool.disk_size
          resources = {
            requests = {
              cpu    = pool.resources.requests.cpu
              memory = pool.resources.requests.memory
            }
            limits = pool.resources.limits != null ? {
              cpu    = pool.resources.limits.cpu
              memory = pool.resources.limits.memory
            } : null
          }
          roles = toset(pool.roles)
        }
      ]
    }
  }
  depends_on = [
    helm_release.opensearch_operator
  ]
}
