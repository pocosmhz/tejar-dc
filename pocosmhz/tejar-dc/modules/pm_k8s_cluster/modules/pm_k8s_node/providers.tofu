terraform {
  required_version = ">= 1.1, <= 1.9.1"
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
      source  = "opentofu/external"
      version = "2.3.5"
    }
    http = {
      source  = "opentofu/http"
      version = "3.5.0"
    }
  }
}

