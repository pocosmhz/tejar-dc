## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.5 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.78.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.78.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_file.meta_data_cloud_config](https://registry.terraform.io/providers/bpg/proxmox/0.78.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.user_data_cloud_config](https://registry.terraform.io/providers/bpg/proxmox/0.78.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_haresource.hares](https://registry.terraform.io/providers/bpg/proxmox/0.78.0/docs/resources/virtual_environment_haresource) | resource |
| [proxmox_virtual_environment_vm.vm](https://registry.terraform.io/providers/bpg/proxmox/0.78.0/docs/resources/virtual_environment_vm) | resource |
| [tls_private_key.pk](https://registry.terraform.io/providers/hashicorp/tls/4.1.0/docs/resources/private_key) | resource |
| [http_http.docker_gpg_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.k8s_gpg_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of admin users | <pre>list(object({<br/>    name    = string<br/>    gecos   = string<br/>    ssh_key = string<br/>  }))</pre> | n/a | yes |
| <a name="input_apiserver_advertise_address"></a> [apiserver\_advertise\_address](#input\_apiserver\_advertise\_address) | API server advertise address | `string` | n/a | yes |
| <a name="input_apiserver_bind_port"></a> [apiserver\_bind\_port](#input\_apiserver\_bind\_port) | API server bind port | `number` | `6443` | no |
| <a name="input_bootstrap_token"></a> [bootstrap\_token](#input\_bootstrap\_token) | Bootstrap token for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_certificate_key"></a> [certificate\_key](#input\_certificate\_key) | Certificate key needed by a cp to join the cluster | `string` | `""` | no |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Number of CPU cores for the VM | `number` | `2` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | CPU type | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for the VM in GB | `number` | `20` | no |
| <a name="input_disks_datastore_id"></a> [disks\_datastore\_id](#input\_disks\_datastore\_id) | ID of the datastore where the disks will be stored | `string` | `"local"` | no |
| <a name="input_ha_group"></a> [ha\_group](#input\_ha\_group) | HA group for the VM | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname of the node | `string` | n/a | yes |
| <a name="input_hosts_entries"></a> [hosts\_entries](#input\_hosts\_entries) | List of host entries for the node | <pre>list(object({<br/>    ip_address = string<br/>    hostname   = string<br/>    node_type  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Image ID to use for the VM | `string` | n/a | yes |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | IP address of the node | `string` | n/a | yes |
| <a name="input_ip_gateway"></a> [ip\_gateway](#input\_ip\_gateway) | IP gateway for the node | `string` | n/a | yes |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version | <pre>object({<br/>    major = number<br/>    minor = number<br/>    patch = number<br/>    build = optional(string, "1.1")<br/>  })</pre> | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory size for the VM in MB | `number` | `2048` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to be used | `string` | `"vmbr0"` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | Networking configuration for the Kubernetes cluster | <pre>object({<br/>    plugin = string<br/>    version = object({<br/>      major = number<br/>      minor = number<br/>      patch = number<br/>    })<br/>    pod_cidr = string<br/>  })</pre> | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Type of the node (cp or worker) | `string` | n/a | yes |
| <a name="input_os_flavor"></a> [os\_flavor](#input\_os\_flavor) | OS flavor for the VM | `string` | `"debian"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type | `string` | `"l26"` | no |
| <a name="input_os_version"></a> [os\_version](#input\_os\_version) | OS version for the VM | `string` | `"bookworm"` | no |
| <a name="input_pve_node"></a> [pve\_node](#input\_pve\_node) | Proxmox node where the VM will be created | `string` | n/a | yes |
| <a name="input_snippets_datastore_id"></a> [snippets\_datastore\_id](#input\_snippets\_datastore\_id) | ID of the datastore where the snippets will be stored | `string` | `"local"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the Kubernetes node | `list(string)` | <pre>[<br/>  "terraform"<br/>]</pre> | no |
| <a name="input_tainted"></a> [tainted](#input\_tainted) | Whether the node is tainted or not | `bool` | `false` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for the node | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the VM. |
| <a name="output_root_private_key_openssh"></a> [root\_private\_key\_openssh](#output\_root\_private\_key\_openssh) | The private key in OpenSSH format. |
| <a name="output_root_public_key_openssh"></a> [root\_public\_key\_openssh](#output\_root\_public\_key\_openssh) | The public key in OpenSSH format. |
