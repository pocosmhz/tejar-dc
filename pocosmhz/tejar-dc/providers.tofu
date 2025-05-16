terraform {
  required_version = ">= 1.1, <= 1.9.1"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
  ssh {
    agent    = var.proxmox_ssh_agent
    username = var.proxmox_ssh_username
    dynamic "node" {
      for_each = var.proxmox_nodes
      content {
        name    = node.key
        address = node.value.ssh_address
        port    = node.value.ssh_port
      }
    }
  }
}
