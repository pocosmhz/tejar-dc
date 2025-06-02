# Kubernetes cluster orchestration
module "k8s_clusters" {
  source                      = "./modules/pm_k8s_cluster"
  for_each                    = var.proxmox_k8s_clusters
  name                        = each.key
  comment                     = each.value.comment
  apiserver_advertise_address = each.value.apiserver_advertise_address
  apiserver_bind_port         = each.value.apiserver_bind_port
  external_url                = each.value.external_url
  k8s_version                 = each.value.k8s_version
  networking                  = each.value.networking
  timezone                    = each.value.timezone
  nodes                       = each.value.nodes
  disks_datastore_id          = var.proxmox_datastore.disks_datastore.id
  tags                        = each.value.tags
  image_list                  = module.pm_ve_vm_debian_cloud_image
  admin_users                 = var.admin_users
  network_bridge              = var.proxmox_network.bridge.id
  ha_groups                   = { for k, v in proxmox_virtual_environment_hagroup.pm_ve_hagroups : k => v }
}
