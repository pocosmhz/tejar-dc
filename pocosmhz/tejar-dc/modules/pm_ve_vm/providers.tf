terraform {
  required_version = ">= 1.8, < 1.11.4"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
    tls = {
      source  = "opentofu/tls"
      version = "4.2.1"
    }
  }
}
