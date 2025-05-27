# Kubernetes cluster
# TODO:
# 1. generate token for all nodes
# 2. pass all variables to the module below to create every node.

resource "random_string" "bootstrap_token_id" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_string" "bootstrap_token_secret" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

module "pm_k8s_node" {
  source                      = "./modules/pm_k8s_node"
  tags                        = var.tags
  apiserver_advertise_address = var.apiserver_advertise_address
  apiserver_bind_port         = var.apiserver_bind_port
  timezone                    = var.timezone
  admin_users                 = var.admin_users
  bootstrap_token             = "${random_string.bootstrap_token_id.result}.${random_string.bootstrap_token_secret.result}"
  ha_group                    = var.ha_groups[each.value.pve_node].id
  network_bridge              = var.network_bridge
  disks_datastore_id          = var.disks_datastore_id
  for_each                    = var.nodes
  hostname                    = each.key
  hosts_entries = each.value.hosts_entries_override != null ? each.value.hosts_entries_override : [for hk, hv in var.nodes : {
    ip_address = split("/", hv.ip_address)[0]
    hostname   = hk
    node_type  = hv.node_type
  }]
  certificate_key = each.value.certificate_key != null ? each.value.certificate_key : ""
  k8s_version     = each.value.version_override != null ? each.value.version_override : var.k8s_version
  networking      = each.value.networking_override != null ? each.value.networking_override : var.networking
  # If networking_override is not provided, use the default networking configuration
  image_id   = each.value.image_list_override != null ? each.value.image_list_override[each.value.pve_node].id : var.image_list[each.value.pve_node].id
  os_flavor  = each.value.os_flavor_override != null ? each.value.os_flavor_override : var.os_flavor
  os_version = each.value.os_version_override != null ? each.value.os_version_override : var.os_version
  pve_node   = each.value.pve_node
  node_type  = each.value.node_type
  ip_address = each.value.ip_address
  ip_gateway = each.value.ip_gateway
  tainted    = each.value.tainted
  cpu_cores  = each.value.cpu_cores
  memory     = each.value.memory
  disk_size  = each.value.disk_size
}
