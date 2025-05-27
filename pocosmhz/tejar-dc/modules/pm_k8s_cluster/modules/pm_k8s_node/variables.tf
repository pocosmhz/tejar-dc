variable "tags" {
  description = "Tags for the Kubernetes node"
  type        = list(string)
  default     = ["terraform"]
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
    plugin   = string
    version  = object({
      major = number
      minor = number
      patch = number
    })
    pod_cidr = string
  })
}

variable "hostname" {
  description = "Hostname of the node"
  type        = string
}

variable "hosts_entries" {
  description = "List of host entries for the node"
  type = list(object({
    ip_address = string
    hostname   = string
    node_type  = string
  }))
}

variable "timezone" {
  description = "Timezone for the node"
  type        = string
  default     = "UTC"
}

variable "node_type" {
  description = "Type of the node (cp or worker)"
  type        = string
}

variable "ip_address" {
  description = "IP address of the node"
  type        = string
}

variable "ip_gateway" {
  description = "IP gateway for the node"
  type        = string
}

variable "tainted" {
  description = "Whether the node is tainted or not"
  type        = bool
  default     = false
}

variable "pve_node" {
  description = "Proxmox node where the VM will be created"
  type        = string
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "l26"
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory size for the VM in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size for the VM in GB"
  type        = number
  default     = 20
}

variable "image_id" {
  description = "Image ID to use for the VM"
  type        = string
}

variable "os_flavor" {
  description = "OS flavor for the VM"
  type        = string
  default     = "debian"
}

variable "os_version" {
  description = "OS version for the VM"
  type        = string
  default     = "bookworm"
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

variable "ha_group" {
  description = "HA group for the VM"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to be used"
  type        = string
  default     = "vmbr0"
}

variable "admin_users" {
  description = "List of admin users"
  type = list(object({
    name    = string
    gecos   = string
    ssh_key = string
  }))
}

variable "bootstrap_token" {
  description = "Bootstrap token for the Kubernetes cluster"
  type        = string
  sensitive = true
}

variable "certificate_key" {
  description = "Certificate key needed by a cp to join the cluster"
  sensitive   = true
  default     = ""
  type        = string
}