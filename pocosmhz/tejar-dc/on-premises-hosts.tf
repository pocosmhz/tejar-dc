# Here we'll create standalone Linux hosts needed.
module "onprem_linux_hosts" {
  source   = "./modules/onprem_host"
  for_each = var.onprem_standalone_hosts

  hostname   = each.key
  ip_address = each.value.ip_address
}
