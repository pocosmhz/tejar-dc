variable "name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "apiserver_advertise_address" {
  description = "API server advertise address"
  type        = string
}

variable "apiserver_bind_port" {
  description = "API server bind port"
  type        = number
  default     = 6443
}

variable "external_url" {
  description = "External URL for the Kubernetes cluster"
  type        = string
  default     = null
}

variable "k8s_version" {
  description = "Kubernetes version"
  type = object({
    major = number
    minor = number
    patch = number
    build = optional(string, "1.1")
  })
}

variable "nodes" {
  description = "Map of nodes in the cluster"
  type = map(object({
    ip_address = string
    ip_gateway = string
    node_type  = string
    tainted    = optional(bool, false)
    pve_node   = optional(string)
    cpu_cores  = optional(number, 2)
    memory     = optional(number, 2048)
    disk_size  = optional(number, 20)
    hosts_entries_override = optional(list(object({
      ip_address = string
      hostname   = string
    })), null)
    version_override = optional(object({
      major = number
      minor = number
      patch = number
      build = optional(string, "1.1")
    }), null)
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
    certificate_key     = optional(string, null)
    ssh_access = optional(object({
      fqdn = string
      port = number
    }), null)
  }))
}
