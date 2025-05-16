# Main module
resource "proxmox_virtual_environment_hagroup" "pm_ve_hagroups" {
  for_each    = var.proxmox_ve_hagroups
  group       = each.key
  comment     = each.value.comment
  nodes       = each.value.nodes
  restricted  = false
  no_failback = false
}
