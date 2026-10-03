# OpenTofu 1.9 cannot move state across resource types. Its removed blocks
# forget old addresses without deleting live objects; imports adopt those same
# objects under the versioned addresses. Retain these blocks for older states.

removed {
  from = kubernetes_namespace.cert_manager
}

import {
  to = kubernetes_namespace_v1.cert_manager
  id = "cert-manager"
}

removed {
  from = kubernetes_namespace.external_dns
}

import {
  to = kubernetes_namespace_v1.external_dns
  id = "external-dns"
}

removed {
  from = kubernetes_namespace.elastic_system
}

import {
  to = kubernetes_namespace_v1.elastic_system
  id = "elastic-system"
}

removed {
  from = kubernetes_namespace.forgejo
}

import {
  to = kubernetes_namespace_v1.forgejo
  id = "forgejo"
}

removed {
  from = kubernetes_namespace.irc
}

import {
  to = kubernetes_namespace_v1.irc
  id = "irc"
}

removed {
  from = kubernetes_namespace.kube_vip_system
}

import {
  to = kubernetes_namespace_v1.kube_vip_system
  id = "kube-vip-system"
}

removed {
  from = kubernetes_namespace.prometheus
}

import {
  to = kubernetes_namespace_v1.prometheus
  id = "prometheus"
}

removed {
  from = kubernetes_namespace.ceph_csi_rbd
}

import {
  to = kubernetes_namespace_v1.ceph_csi_rbd
  id = "ceph-csi-rbd"
}

removed {
  from = kubernetes_namespace.traefik
}

import {
  to = kubernetes_namespace_v1.traefik
  id = "traefik"
}

removed {
  from = kubernetes_secret.external_dns_sa_key
}

import {
  to = kubernetes_secret_v1.external_dns_sa_key
  id = "external-dns/external-dns-sa-key"
}
