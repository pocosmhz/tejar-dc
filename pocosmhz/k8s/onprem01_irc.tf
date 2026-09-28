# Private IRC service: Ergo over TLS and The Lounge over HTTPS.
resource "kubernetes_namespace" "irc" {
  metadata {
    name = "irc"
  }
}

# The password is generated once and can be retrieved by an administrator from
# this Secret to bootstrap accounts via the local-only Ergo listener.
resource "random_password" "irc_oper" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "irc_oper" {
  metadata {
    name      = "ergo-oper-credentials"
    namespace = kubernetes_namespace.irc.id
  }
  data = {
    username = "admin"
    password = random_password.irc_oper.result
  }
  type = "Opaque"
}

# HTTP-01 challenges are served through the existing nginx ingress controller.
# The IRC certificate is mounted into Ergo, which terminates TLS itself.
resource "kubernetes_manifest" "irc_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "ergo-irc"
      namespace = kubernetes_namespace.irc.id
    }
    spec = {
      secretName = "ergo-irc-tls"
      dnsNames   = [var.k8s_clusters["onprem01"].irc.irc_domain]
      issuerRef = {
        name  = "letsencrypt"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.cluster_issuer_letsencrypt,
    helm_release.ingress_nginx,
    helm_release.external_dns
  ]
}

resource "kubernetes_manifest" "chat_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "thelounge-https"
      namespace = kubernetes_namespace.irc.id
    }
    spec = {
      secretName = "thelounge-https-tls"
      dnsNames   = [var.k8s_clusters["onprem01"].irc.chat_domain]
      issuerRef = {
        name  = "letsencrypt"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.cluster_issuer_letsencrypt,
    helm_release.ingress_nginx,
    helm_release.external_dns
  ]
}

# Publish the chat hostname before The Lounge is deployed. cert-manager creates
# its own temporary Ingress for the HTTP-01 challenge.
resource "google_dns_record_set" "irc_chat" {
  provider     = google.onprem01
  managed_zone = google_dns_managed_zone.external_dns_zone.name
  name         = "${trimsuffix(var.k8s_clusters["onprem01"].irc.chat_domain, ".")}."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${trimsuffix(var.k8s_clusters["onprem01"].irc.target, ".")}."]
}

resource "kubernetes_network_policy_v1" "ergo" {
  metadata {
    name      = "ergo-ingress"
    namespace = kubernetes_namespace.irc.id
  }
  spec {
    pod_selector {
      match_labels = { "app.kubernetes.io/name" = "ergo" }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = "ingress-nginx" }
        }
      }
      from {
        pod_selector {
          match_labels = { "app.kubernetes.io/name" = "thelounge" }
        }
      }
      ports {
        port     = "6697"
        protocol = "TCP"
      }
    }
  }
}

resource "helm_release" "ergo" {
  name      = "ergo"
  chart     = "${path.module}/source/helm/ergo"
  namespace = kubernetes_namespace.irc.id

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [templatefile("${path.module}/source/helm/ergo/ergo-values.tpl.yml", {
    irc_conf           = var.k8s_clusters["onprem01"].irc
    oper_password_hash = random_password.irc_oper.bcrypt_hash
  })]

  depends_on = [
    kubernetes_manifest.irc_certificate,
    kubernetes_network_policy_v1.ergo,
    helm_release.ceph_csi_rbd
  ]
}

# Resolve the ClusterIP after Ergo is created. The Lounge connects to this IP
# under the public IRC hostname, preserving full TLS hostname verification.
data "kubernetes_service_v1" "ergo" {
  metadata {
    name      = "ergo"
    namespace = kubernetes_namespace.irc.id
  }
  depends_on = [helm_release.ergo]
}

resource "kubernetes_network_policy_v1" "thelounge" {
  metadata {
    name      = "thelounge-restricted"
    namespace = kubernetes_namespace.irc.id
  }
  spec {
    pod_selector {
      match_labels = { "app.kubernetes.io/name" = "thelounge" }
    }
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = "ingress-nginx" }
        }
      }
      ports {
        port     = "9000"
        protocol = "TCP"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = { "app.kubernetes.io/name" = "ergo" }
        }
      }
      ports {
        port     = "6697"
        protocol = "TCP"
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = "kube-system" }
        }
        pod_selector {
          match_labels = { "k8s-app" = "kube-dns" }
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

    # Permit public link previews and TLS connections to other IRC networks,
    # while blocking requests into the LAN and cluster.
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
      ports {
        port     = "80"
        protocol = "TCP"
      }
      ports {
        port     = "443"
        protocol = "TCP"
      }
      ports {
        port     = "6697"
        protocol = "TCP"
      }
    }
  }
}

resource "helm_release" "thelounge" {
  name      = "thelounge"
  chart     = "${path.module}/source/helm/thelounge"
  namespace = kubernetes_namespace.irc.id

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    templatefile("${path.module}/source/helm/thelounge/thelounge-values.tpl.yml", {
      irc_conf       = var.k8s_clusters["onprem01"].irc
      irc_service_ip = data.kubernetes_service_v1.ergo.spec[0].cluster_ip
    }),
    yamlencode({
      chartRevision = sha256(join("", [for file in sort(fileset("${path.module}/source/helm/thelounge", "**")) : filesha256("${path.module}/source/helm/thelounge/${file}")]))
    })
  ]

  depends_on = [
    kubernetes_manifest.chat_certificate,
    google_dns_record_set.irc_chat,
    kubernetes_network_policy_v1.thelounge,
    helm_release.ceph_csi_rbd,
    helm_release.ingress_nginx
  ]
}
