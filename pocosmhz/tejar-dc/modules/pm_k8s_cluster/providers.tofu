terraform {
  required_version = ">= 1.1, <= 1.9.1"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.94.0"
    }
    tls = {
      source  = "opentofu/tls"
      version = "4.2.1"
    }
    random = {
      source  = "opentofu/random"
      version = "3.7.2"
    }
  }
}

