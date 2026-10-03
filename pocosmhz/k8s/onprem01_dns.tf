# Networking components
# 3. External DNS

# DNS and external-dns configuration for Kubernetes cluster onprem01
data "google_dns_managed_zone" "onprem01_parent_dns" {
  count    = var.k8s_clusters["onprem01"].external_dns.parent_zone != null ? 1 : 0
  name     = var.k8s_clusters["onprem01"].external_dns.parent_zone.name
  provider = google.onprem01
}

resource "google_dns_managed_zone" "external_dns_zone" {
  name        = var.k8s_clusters["onprem01"].external_dns.zone.name
  dns_name    = "${var.k8s_clusters["onprem01"].external_dns.zone.dnsname}."
  description = "External DNS zone for Kubernetes cluster"
  project     = var.k8s_clusters["onprem01"].providers.gcp.project
  provider    = google.onprem01
}

# This is only needed if you use external-dns with a child zone
resource "google_dns_record_set" "external_dns_record" {
  count        = var.k8s_clusters["onprem01"].external_dns.parent_zone != null ? 1 : 0
  name         = "${var.k8s_clusters["onprem01"].external_dns.zone.dnsname}."
  type         = "NS"
  ttl          = 21600
  managed_zone = data.google_dns_managed_zone.onprem01_parent_dns[0].name
  rrdatas      = google_dns_managed_zone.external_dns_zone.name_servers
  project      = var.k8s_clusters["onprem01"].providers.gcp.project
  provider     = google.onprem01
}

# Service account for external-dns
resource "google_service_account" "external_dns_sa" {
  account_id   = "external-dns-admin"
  display_name = "External DNS Admin Service Account"
  description  = "Service account for managing external DNS records"
  project      = var.k8s_clusters["onprem01"].providers.gcp.project
  provider     = google.onprem01
}

resource "google_project_iam_member" "external_dns_sa_role" {
  project  = var.k8s_clusters["onprem01"].providers.gcp.project
  role     = "roles/dns.admin"
  member   = "serviceAccount:${google_service_account.external_dns_sa.email}"
  provider = google.onprem01
}

resource "google_service_account_key" "external_dns_sa_key" {
  service_account_id = google_service_account.external_dns_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
  provider           = google.onprem01
}

# external-dns service configuration
resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret_v1" "external_dns_sa_key" {
  metadata {
    name      = "external-dns-sa-key"
    namespace = kubernetes_namespace_v1.external_dns.id
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.external_dns_sa_key.private_key)
  }
  type = "Opaque"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.23.0"
  namespace  = kubernetes_namespace_v1.external_dns.id
  values = [
    templatefile("${path.module}/source/helm/external-dns/external-dns-values.tpl.yml", {
      provider             = "google"
      google_project       = var.k8s_clusters["onprem01"].providers.gcp.project
      google_sa_secret     = kubernetes_secret_v1.external_dns_sa_key.metadata[0].name
      google_sa_secret_key = "credentials.json"
      txtowner_id          = "default"
      policy               = "sync"
      service_account = {
        create = false
        name   = "default"
      }
      domain_filters = yamlencode({
        domainFilters = [var.k8s_clusters["onprem01"].external_dns.zone.dnsname]
      })
      metrics_enabled                = false
      metrics_servicemonitor_enabled = false
      metrics_servicemonitor_labels = yamlencode({
        release = "prometheus"
      })
    })
  ]
  depends_on = [kubernetes_network_policy_v1.external_dns]
  timeout    = "1200"
}

# Preserve the Bitnami chart's access policy under independent OpenTofu ownership.
# Use a distinct name so Helm can remove its old policy during the chart migration.
resource "kubernetes_network_policy_v1" "external_dns" {
  metadata {
    name      = "external-dns-access"
    namespace = kubernetes_namespace_v1.external_dns.id
  }
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/instance" = "external-dns"
        "app.kubernetes.io/name"     = "external-dns"
      }
    }
    policy_types = ["Ingress", "Egress"]
    ingress {
      ports {
        port     = "7979"
        protocol = "TCP"
      }
    }
    egress {}
  }
}

# The official chart does not create a PodDisruptionBudget.
# Create the replacement after Helm removes the old budget to avoid overlapping PDBs.
resource "kubernetes_pod_disruption_budget_v1" "external_dns" {
  metadata {
    name      = "external-dns-availability"
    namespace = kubernetes_namespace_v1.external_dns.id
  }
  spec {
    max_unavailable = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "external-dns"
        "app.kubernetes.io/name"     = "external-dns"
      }
    }
  }
  depends_on = [helm_release.external_dns]
}
