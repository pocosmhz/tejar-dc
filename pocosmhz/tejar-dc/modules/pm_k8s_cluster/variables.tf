variable "name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "comment" {
  description = "Comment for the Kubernetes cluster"
  type        = string
  default     = ""
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

variable "timezone" {
  description = "Timezone for the Kubernetes cluster"
  type        = string
  default     = "UTC"
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

variable "networking" {
  description = "Networking configuration for the Kubernetes cluster"
  type = object({
    plugin = string
    version = object({
      major = number
      minor = number
      patch = number
    })
    pod_cidr = string
  })
}

variable "os_flavor" {
  description = "Operating system flavor for the nodes"
  type        = string
  default     = "debian"
}
variable "os_version" {
  description = "Operating system version for the nodes"
  type        = string
  default     = "bookworm"
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
  }))
}

variable "tags" {
  description = "Tags for the Kubernetes cluster"
  type        = list(string)
  default     = []
}

variable "admin_users" {
  description = "List of admin users"
  type = list(object({
    name    = string
    gecos   = string
    ssh_key = string
  }))
}

variable "image_list" {
  description = "List of images to use for the nodes"
  type = map(object({
    id   = string
    size = number
  }))
}

variable "snippets_datastore_id" {
  description = "ID of the datastore where the snippets will be stored"
  type        = string
  default     = "local"
}

variable "disks_datastore_id" {
  description = "ID of the datastore where the disks will be stored"
  type        = string
  default     = "local"
}

variable "ha_groups" {
  description = "HA groups for the Kubernetes cluster"
  type = map(object({
    comment     = string
    group       = string
    id          = string
    no_failback = optional(bool, false)
    restricted  = optional(bool, false)
    nodes       = map(number)
  }))
  default = {}
}

variable "network_bridge" {
  description = "Network bridge to be used"
  type        = string
  default     = "vmbr0"
}
