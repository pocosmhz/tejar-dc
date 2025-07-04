# Bastion host we will need for different tasks
module "pm_jump_host" {
  source             = "./modules/pm_ve_vm_sshpiper"
  hostname           = var.proxmox_jump_host.hostname
  ip_address         = var.proxmox_jump_host.ip_address
  ip_gateway         = var.proxmox_jump_host.ip_gateway
  node_id            = var.proxmox_jump_host.node
  disks_datastore_id = var.proxmox_datastore.disks_datastore.id
  disk_size          = 3 # 3 GB is the minimum size for cloud images
  memory             = 384
  network_bridge     = var.proxmox_network.bridge.id
  image_id           = module.pm_ve_vm_debian12_cloud_image[var.proxmox_jump_host.node].id
  timezone           = var.proxmox_timezone
  admin_users        = var.admin_users
  hosts = flatten(
    [for k, v in module.k8s_clusters : v.hosts]
  )
  ha_group = proxmox_virtual_environment_hagroup.pm_ve_hagroups["pve01"].id
  tags     = ["debian", "ssh-piper"]
}
