# Here we'll create standalone Linux hosts needed.
module "pm_linux_hosts" {
  source   = "./modules/pm_ve_vm"
  for_each = var.proxmox_standalone_hosts

  hostname           = each.key
  ip_address         = each.value.ip_address
  ip_gateway         = each.value.ip_gateway
  node_id            = each.value.node
  disks_datastore_id = var.proxmox_datastore.disks_datastore.id
  disk_size          = each.value.disk_size
  memory             = each.value.memory
  cpu_cores          = each.value.cpu_cores
  network_bridge     = var.proxmox_network.bridge.id
  image_id = each.value.image_id != null ? each.value.image_id : (
    each.value.template_name == "debian12" ? module.pm_ve_vm_debian12_cloud_image[each.value.node].id :
    each.value.template_name == "debian13" ? module.pm_ve_vm_debian13_cloud_image[each.value.node].id :
    null
  )
  timezone    = var.proxmox_timezone
  admin_users = var.admin_users
  # ha_group = proxmox_virtual_environment_hagroup.pm_ve_hagroups["pve01"].id
  packages           = each.value.packages
  tags               = each.value.tags
  user_data_template = each.value.template_name
}
