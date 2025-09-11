terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}
