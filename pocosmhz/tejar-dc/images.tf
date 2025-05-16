# Here we set up all Proxmox images needed, in all nodes
module "pm_ve_vm_debian_cloud_image" {
  source       = "./modules/pm_ve_download_file"
  for_each     = var.proxmox_nodes
  content_type = "iso"
  datastore_id = var.proxmox_datastore.local_datastore.id
  node_name    = each.key
  url          = var.proxmox_vm_default_images.debian.url
  file_name    = var.proxmox_vm_default_images.debian.file_name
}
