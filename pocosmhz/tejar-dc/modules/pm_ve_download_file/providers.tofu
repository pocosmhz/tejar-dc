terraform {
  required_version = ">= 1.10, <= 1.13.2"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
  }
}

