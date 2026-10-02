# ELK / ECK configuration for Kubernetes on-premises
# Uses the official Elastic Cloud on Kubernetes (ECK) operator

resource "kubernetes_namespace" "elastic_system" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "eck_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "3.5.0"
  namespace  = kubernetes_namespace.elastic_system.id
  depends_on = [kubernetes_namespace.elastic_system]
}

resource "kubernetes_manifest" "elasticsearch_cluster" {
  for_each = var.k8s_clusters["onprem01"].elasticsearch != null ? var.k8s_clusters["onprem01"].elasticsearch.clusters : {}
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1"
    kind       = "Elasticsearch"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.elastic_system.id
    }
    spec = {
      version = each.value.version
      nodeSets = [
        for ns in each.value.node_sets : {
          name  = ns.name
          count = ns.replicas
          config = {
            "node.roles"            = ns.roles
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
