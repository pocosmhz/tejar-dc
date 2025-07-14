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
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns_sa_key" {
  metadata {
    name      = "external-dns-sa-key"
    namespace = kubernetes_namespace.external_dns.id
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.external_dns_sa_key.private_key)
  }
  type = "Opaque"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "8.9.2"
  namespace  = kubernetes_namespace.external_dns.id
  values = [
    templatefile("${path.module}/source/helm/external-dns/external-dns-values.tpl.yml", {
      provider             = "google"
      google_project       = var.k8s_clusters["onprem01"].providers.gcp.project
      google_sa_secret     = kubernetes_secret.external_dns_sa_key.metadata[0].name
      google_sa_secret_key = "credentials.json"
      txtowner_id          = ""
      policy               = "sync"
      service_account = yamlencode({
        create = false
      })
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
  timeout = "1200"
}
