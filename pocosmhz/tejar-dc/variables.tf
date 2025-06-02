# Proxmox hypervisor variables
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://your-proxmox-server:8006/"
}

variable "proxmox_username" {
  description = "Proxmox API username"
  type        = string
  default     = "root@pam"
  sensitive   = true
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  default     = "your-password"
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip SSL verification"
  type        = bool
  default     = true
}

variable "proxmox_ssh_agent" {
  description = "Use SSH agent for authentication"
  type        = bool
  default     = false
}

variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox nodes"
  type        = string
  default     = "root"
  sensitive   = true
}

variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = map(object({
    ssh_address = string
    ssh_port    = number
  }))
  default = {
    pve01 = {
      ssh_address = "pve01.example.org"
      ssh_port    = 22
    }
  }
}

# Proxmox default values
variable "proxmox_vm_default_images" {
  description = "Default images for Proxmox VMs"
  type = map(object({
    url       = string
    file_name = string
  }))
  default = {
    debian = {
      url       = "https://cloud.debian.org/images/cloud/bookworm/20250528-2126/debian-12-genericcloud-amd64-20250528-2126.qcow2"
      file_name = "debian-12-genericcloud-amd64.img"
    }
  }
}

variable "proxmox_datastore" {
  description = "Proxmox datastore configuration"
  type = map(object({
    id = string
  }))
  default = {
    disks_datastore = {
      id = "pool1"
    }
    iso_datastore = {
      id = "local"
    }
    local_datastore = {
      id = "local"
    }
  }
}

variable "proxmox_network" {
  description = "Proxmox network configuration"
  type = map(object({
    id   = string
    name = string
  }))
  default = {
    bridge = {
      id   = "vmbr0"
      name = "vmbr0"
    }
  }
}

variable "proxmox_timezone" {
  description = "Proxmox timezone"
  type        = string
  default     = "Europe/Madrid"
}

# Proxmox HA settings
variable "proxmox_ve_hagroups" {
  description = "Proxmox HA groups"
  type = map(object({
    name    = string
    comment = string
    nodes   = map(number)
  }))
  default = {
    pve01 = {
      name    = "pve01"
      comment = "PVE01 HA group"
      nodes = {
        pve01 = 3
        pve02 = 2
        pve03 = 1
      }
    }
    pve02 = {
      name    = "pve02"
      comment = "PVE02 HA group"
      nodes = {
        pve02 = 3
        pve03 = 2
        pve01 = 1
      }
    }
    pve03 = {
      name    = "pve03"
      comment = "PVE03 HA group"
      nodes = {
        pve03 = 3
        pve01 = 2
        pve02 = 1
      }
    }
  }
}

# Proxmox jump host
variable "proxmox_jump_host" {
  description = "Proxmox jump host configuration"
  type = object({
    node       = string
    hostname   = string
    ip_address = string
    ip_gateway = string
  })
  default = {
    node       = "pve01"
    hostname   = "jh01"
    ip_address = "192.168.1.4/24"
    ip_gateway = "192.168.1.1"
  }
}

# VM default values
variable "admin_users" {
  description = "List of admin users"
  type = list(object({
    name    = string
    gecos   = string
    ssh_key = string
  }))
  default = [
    {
      name    = "admin"
      gecos   = "Admin User"
      ssh_key = "ssh-rsa AAAABXXXXXXXXXXX admin@randomhost"
    }
  ]
}

# Proxmox Kubernetes clusters
variable "proxmox_k8s_clusters" {
  description = "Proxmox Kubernetes clusters"
  type = map(object({
    comment                     = string
    apiserver_advertise_address = string
    apiserver_bind_port         = number
    external_url                = optional(string, null)
    k8s_version = object({
      major = number
      minor = number
      patch = number
      build = optional(string, "1.1")
    })
    networking = object({
      plugin = string
      version = object({
        major = number
        minor = number
        patch = number
      })
      pod_cidr = string
    })
    os_flavor  = optional(string, "debian")
    os_version = optional(string, "bookworm")
    nodes = map(object({
      ip_address = string
      ip_gateway = string
      cpu_cores  = number
      node_type  = string
      tainted    = bool
      pve_node   = string
      memory     = number
      disk_size  = number
      # Optional parameters, per node
      hosts_entries_override = optional(list(object({
        ip_address = string
        hostname   = string
      })), null)
      version_override = optional(object({
        major = number
        minor = number
        patch = number
        build = optional(string, "1.1")
      }))
      networking_override = optional(object({
        plugin = string
        version = object({
          major = number
          minor = number
          patch = number
        })
        pod_cidr = string
      }), null)
      image_list_override = optional(map(object({
        id   = string
        size = number
      })), null)
      os_flavor_override  = optional(string, "debian")
      os_version_override = optional(string, "bookworm")
      certificate_key     = optional(string, "")
      ssh_access = optional(object({
        fqdn = string
        port = number
      }), null)
    }))
    tags     = list(string)
    timezone = optional(string, "UTC")
  }))
  default = {
    k8s01 = {
      comment                     = "Kubernetes cluster 01"
      apiserver_advertise_address = "192.168.1.5"
      apiserver_bind_port         = 6443
      tags                        = ["k8s", "debian"]
      timezone                    = "Europe/Madrid"
      k8s_version = {
        major = 1
        minor = 31
        patch = 2
        build = "1.1"
      }
      networking = {
        plugin = "calico"
        version = {
          major = 3
          minor = 30
          patch = 0
        }
        pod_cidr = "172.20.0.0/16"
      }
      nodes = {
        k8s01cp01 = {
          ip_address = "192.168.1.5/24"
          ip_gateway = "192.168.1.1"
          node_type  = "cp"
          tainted    = true
          pve_node   = "pve01"
          cpu_cores  = 2
          memory     = 4096
          disk_size  = 20
          ssh_access = {
            fqdn = "your-k8s-cp-hostname.example.com"
            port = 22
          }
        }
        k8s01w01 = {
          ip_address = "192.168.1.6/24"
          ip_gateway = "192.168.1.1"
          node_type  = "worker"
          tainted    = false
          pve_node   = "pve02"
          cpu_cores  = 2
          memory     = 4096
          disk_size  = 20
        }
      }
    }
  }
}
