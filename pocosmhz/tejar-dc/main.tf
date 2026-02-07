# Main module

# NOTE: After upgrading to Proxmox VE 9.x, the HA groups are no longer supported. Therefore, this resource is commented out.
# Check https://github.com/bpg/terraform-provider-proxmox/issues/2097

# resource "proxmox_virtual_environment_hagroup" "pm_ve_hagroups" {
#   for_each    = var.proxmox_ve_hagroups
#   group       = each.key
#   comment     = each.value.comment
#   nodes       = each.value.nodes
#   restricted  = false
#   no_failback = false
# }
