terraform {
  required_version = ">= 1.1, <= 1.9.1"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
    tls = {
      source  = "opentofu/tls"
      version = "4.2.1"
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

