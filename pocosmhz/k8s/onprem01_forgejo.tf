# Forgejo SCM
resource "kubernetes_namespace" "forgejo" {
  metadata {
    name = "forgejo"
  }
}

# Limit the blast radius of an application compromise. Forgejo can resolve DNS
# and reach public Git/web endpoints, but cannot pivot into the nodes or LAN.
resource "kubernetes_network_policy_v1" "forgejo" {
  metadata {
    name      = "forgejo-restricted"
    namespace = kubernetes_namespace.forgejo.id
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name"     = "forgejo"
        "app.kubernetes.io/instance" = "forgejo"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }

      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }

        pod_selector {
          match_labels = {
            "k8s-app" = "kube-dns"
          }
        }
      }

      ports {
        port     = "53"
        protocol = "UDP"
      }

      ports {
        port     = "53"
        protocol = "TCP"
      }
    }

    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
          except = [
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.168.0.0/16"
          ]
        }
      }
    }
  }
}

resource "helm_release" "forgejo" {
  name      = "forgejo"
  chart     = "oci://code.forgejo.org/forgejo-helm/forgejo"
  version   = "17.1.4"
  namespace = kubernetes_namespace.forgejo.id

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true

  values = [
    templatefile("${path.module}/source/helm/forgejo/forgejo-values.tpl.yml", {
      forgejo_conf = var.k8s_clusters["onprem01"].forgejo
    })
  ]

  depends_on = [
    kubernetes_namespace.forgejo,
    kubernetes_network_policy_v1.forgejo,
    helm_release.cert_manager,
    helm_release.ceph_csi_rbd,
    helm_release.ingress_nginx
  ]
}
