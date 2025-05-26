variable "hostname" {
  description = "Name of the VM"
  type        = string
}

variable "node_id" {
  description = "Proxmox node ID where the VM will be created"
  type        = string
}

variable "image_id" {
  description = "ID of the image to be used"
  type        = string
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

variable "disk_size" {
  description = "Size of the disk in GB"
  type        = number
  default     = 10
}

variable "network_bridge" {
  description = "Network bridge to be used"
  type        = string
  default     = "vmbr0"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "memory" {
  description = "Dedicated memory size in MB"
  type        = number
  default     = 512
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "l26"
}

variable "ip_address" {
  description = "IP address of the VM"
  type        = string
}

variable "ip_gateway" {
  description = "Gateway IP address"
  type        = string
}

variable "timezone" {
  description = "Timezone for the VM"
  type        = string
  default     = "UTC"
}

variable "tags" {
  description = "Tags for the VM"
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

variable "ha_group" {
  description = "HA group for the VM"
  type        = string
}

variable "hosts" {
  description = "List of hosts for sshpiperd to provide access to"
  type = list(object({
    name    = string
    ip      = string
    ssh_key = string
  }))
}
variable "sshpiper_version" {
  description = "Version of SSHPiper to be used"
  type        = string
  default     = "1.4.8"
}
