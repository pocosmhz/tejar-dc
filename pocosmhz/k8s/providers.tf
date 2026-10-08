terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "3.3.0"
    }
    helm = {
      source  = "opentofu/helm"
      version = "3.3.0"
    }
    http = {
      source  = "opentofu/http"
      version = "3.6.2"
    }
    google = {
      source  = "opentofu/google"
      version = "8.5.0"
    }
    random = {
      source  = "opentofu/random"
      version = "3.9.1"
    }
  }
}

provider "kubernetes" {
  host     = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].external_url
  token    = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].terraform_token
  insecure = true
  # cluster_ca_certificate = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].cluster_ca_cert
  # tls_server_name        = "kubernetes.default.svc"
}

provider "helm" {
  kubernetes = {
    host     = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].external_url
    token    = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].terraform_token
    insecure = true
    # cluster_ca_certificate = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].cluster_ca_cert
    # tls_server_name        = "kubernetes.default.svc"
  }
}

provider "google" {
  project = var.k8s_clusters["onprem01"].providers.gcp.project
  region  = var.k8s_clusters["onprem01"].providers.gcp.region
  zone    = var.k8s_clusters["onprem01"].providers.gcp.zone
  alias   = "onprem01"
}
