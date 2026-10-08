# ELK / ECK configuration for Kubernetes on-premises
# Uses the official Elastic Cloud on Kubernetes (ECK) operator

locals {
  kibana_clusters = {
    for name, cluster in(var.k8s_clusters["onprem01"].elasticsearch != null ? var.k8s_clusters["onprem01"].elasticsearch.clusters : {}) :
    name => cluster if cluster.kibana != null
  }
}

resource "kubernetes_namespace_v1" "elastic_system" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "eck_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "3.5.0"
  namespace  = kubernetes_namespace_v1.elastic_system.id
  depends_on = [kubernetes_namespace_v1.elastic_system]
}

resource "kubernetes_manifest" "elasticsearch_cluster" {
  for_each = var.k8s_clusters["onprem01"].elasticsearch != null ? var.k8s_clusters["onprem01"].elasticsearch.clusters : {}
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1"
    kind       = "Elasticsearch"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace_v1.elastic_system.id
    }
    spec = {
      version = each.value.version
      nodeSets = [
        for ns in each.value.node_sets : {
          name  = ns.name
          count = ns.replicas
          config = {
            # ECK's free-form config is read back as JSON tuples, not typed lists.
            # Normalize the input type to prevent an invisible provider diff.
            "node.roles"            = jsondecode(jsonencode(ns.roles))
            "node.store.allow_mmap" = false
          }
          podTemplate = {
            metadata = {}
            spec = {
              containers = [
                {
                  name = "elasticsearch"
                  resources = {
                    limits = {
                      cpu    = ns.resources.limits.cpu
                      memory = ns.resources.limits.memory
                    }
                    requests = {
                      cpu    = ns.resources.requests.cpu
                      memory = ns.resources.requests.memory
                    }
                  }
                }
              ]
            }
          }
          volumeClaimTemplates = [
            {
              metadata = {
                name = "elasticsearch-data"
              }
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = ns.disk_size
                  }
                }
              }
            }
          ]
        }
      ]
    }
  }
  depends_on = [helm_release.eck_operator]
}

resource "kubernetes_manifest" "kibana" {
  for_each = local.kibana_clusters
  manifest = {
    apiVersion = "kibana.k8s.elastic.co/v1"
    kind       = "Kibana"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace_v1.elastic_system.id
    }
    spec = {
      # Keep the complete version in sync with the associated Elasticsearch.
      version          = each.value.version
      count            = each.value.kibana.replicas
      elasticsearchRef = { name = each.key }
      config = {
        "server.publicBaseUrl" = "https://${each.value.kibana.domain}"
      }
      http = {
        service = { spec = { type = "ClusterIP" } }
        # Traefik terminates public TLS; ECK still secures the connection to ES.
        tls = { selfSignedCertificate = { disabled = true } }
      }
      podTemplate = {
        # ECK defaults this empty metadata object on admission.
        metadata = {}
        spec = {
          containers = [{
            name      = "kibana"
            resources = each.value.kibana.resources
          }]
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.elasticsearch_cluster]
}

resource "kubernetes_ingress_v1" "kibana" {
  for_each = local.kibana_clusters
  metadata {
    name      = "${each.key}-kibana"
    namespace = kubernetes_namespace_v1.elastic_system.id
    annotations = merge({
      "cert-manager.io/cluster-issuer"                   = "letsencrypt"
      "external-dns.alpha.kubernetes.io/hostname"        = each.value.kibana.domain
      "external-dns.alpha.kubernetes.io/ttl"             = "300"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
      }, each.value.kibana.target != "" ? {
      "external-dns.alpha.kubernetes.io/target" = each.value.kibana.target
    } : {})
  }
  spec {
    ingress_class_name = each.value.kibana.ingress_class
    rule {
      host = each.value.kibana.domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${each.key}-kb-http"
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [each.value.kibana.domain]
      secret_name = "${each.key}-kibana-tls"
    }
  }
  depends_on = [
    kubernetes_manifest.kibana,
    kubernetes_manifest.cluster_issuer_letsencrypt,
    helm_release.traefik,
    helm_release.external_dns
  ]
}
