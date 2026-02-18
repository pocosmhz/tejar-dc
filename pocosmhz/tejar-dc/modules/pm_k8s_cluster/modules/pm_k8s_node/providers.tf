terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.94.0"
    }
    tls = {
      source  = "opentofu/tls"
      version = "4.2.1"
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
