terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
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
  kubernetes {
    host     = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].external_url
    token    = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].terraform_token
    insecure = true
    # cluster_ca_certificate = data.terraform_remote_state.tejar_dc.outputs.k8s_cluster_data["onprem01"].cluster_ca_cert
    # tls_server_name        = "kubernetes.default.svc"
  }
}
