## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.78.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.78.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_file.meta_data_cloud_config](https://registry.terraform.io/providers/bpg/proxmox/0.78.2/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.user_data_cloud_config](https://registry.terraform.io/providers/bpg/proxmox/0.78.2/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_haresource.hares](https://registry.terraform.io/providers/bpg/proxmox/0.78.2/docs/resources/virtual_environment_haresource) | resource |
| [proxmox_virtual_environment_vm.vm](https://registry.terraform.io/providers/bpg/proxmox/0.78.2/docs/resources/virtual_environment_vm) | resource |
| [tls_private_key.pk](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of admin users | <pre>list(object({<br/>    name    = string<br/>    gecos   = string<br/>    ssh_key = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Number of CPU cores | `number` | `1` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | CPU type | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the disk in GB | `number` | `10` | no |
| <a name="input_disks_datastore_id"></a> [disks\_datastore\_id](#input\_disks\_datastore\_id) | ID of the datastore where the disks will be stored | `string` | `"local"` | no |
| <a name="input_ha_group"></a> [ha\_group](#input\_ha\_group) | HA group for the VM | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Name of the VM | `string` | n/a | yes |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | List of hosts for sshpiperd to provide access to | <pre>list(object({<br/>    name    = string<br/>    ip      = string<br/>    ssh_key = string<br/>  }))</pre> | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | ID of the image to be used | `string` | n/a | yes |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | IP address of the VM | `string` | n/a | yes |
| <a name="input_ip_gateway"></a> [ip\_gateway](#input\_ip\_gateway) | Gateway IP address | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Dedicated memory size in MB | `number` | `512` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to be used | `string` | `"vmbr0"` | no |
| <a name="input_node_id"></a> [node\_id](#input\_node\_id) | Proxmox node ID where the VM will be created | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type | `string` | `"l26"` | no |
| <a name="input_snippets_datastore_id"></a> [snippets\_datastore\_id](#input\_snippets\_datastore\_id) | ID of the datastore where the snippets will be stored | `string` | `"local"` | no |
| <a name="input_sshpiper_version"></a> [sshpiper\_version](#input\_sshpiper\_version) | Version of SSHPiper to be used | `string` | `"1.5.0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the VM | `list(string)` | `[]` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for the VM | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the VM. |
| <a name="output_root_private_key_openssh"></a> [root\_private\_key\_openssh](#output\_root\_private\_key\_openssh) | The private key in OpenSSH format. |
| <a name="output_root_public_key_openssh"></a> [root\_public\_key\_openssh](#output\_root\_public\_key\_openssh) | The public key in OpenSSH format. |
