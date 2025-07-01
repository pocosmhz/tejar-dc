terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}
