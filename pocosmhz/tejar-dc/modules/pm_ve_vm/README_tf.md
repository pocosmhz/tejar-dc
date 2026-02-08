# Terraform Reference

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 1.11.4 |

## Providers

| Name | Version |
|------|---------|
| bpg/proxmox | 0.94.0 |
| hashicorp/tls | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| `proxmox_virtual_environment_file.meta_data_cloud_config` | resource |
| `proxmox_virtual_environment_file.user_data_cloud_config` | resource |
| `proxmox_virtual_environment_vm.vm` | resource |
| `proxmox_virtual_environment_haresource.hares` | resource |
| `tls_private_key.pk` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `admin_users` | List of admin users | `list(object({ name = string, gecos = string, ssh_key = string }))` | n/a | yes |
| `cpu_cores` | Number of CPU cores | `number` | `1` | no |
| `cpu_type` | CPU type | `string` | `"x86-64-v2-AES"` | no |
| `disk_size` | Size of the disk in GB | `number` | `10` | no |
| `disks_datastore_id` | ID of the datastore where the disks will be stored | `string` | `"local"` | no |
| `ha_group` | HA group for the VM | `string` | `null` | no |
| `hostname` | Name of the VM | `string` | n/a | yes |
| `image_id` | ID of the image to be used | `string` | n/a | yes |
| `ip_address` | IP address of the VM | `string` | n/a | yes |
| `ip_gateway` | Gateway IP address | `string` | n/a | yes |
| `memory` | Dedicated memory size in MB | `number` | `512` | no |
| `network_bridge` | Network bridge to be used | `string` | `"vmbr0"` | no |
| `node_id` | Proxmox node ID where the VM will be created | `string` | n/a | yes |
| `os_type` | Operating system type | `string` | `"l26"` | no |
| `packages` | List of packages to be installed on the VM | `list(string)` | `[]` | no |
| `parameters` | Generic parameters object for custom VM configuration | `any` | `{}` | no |
| `snippets_datastore_id` | ID of the datastore where the snippets will be stored | `string` | `"local"` | no |
| `tags` | Tags for the VM | `list(string)` | `[]` | no |
| `timezone` | Timezone for the VM | `string` | `"UTC"` | no |
| `user_data_template` | Template file path for user-data cloud-config | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the created VM |
| `ip` | IP address of the VM |
| `ssh_key` | SSH private key for root access |
| `ssh_public_key` | SSH public key for root access |
