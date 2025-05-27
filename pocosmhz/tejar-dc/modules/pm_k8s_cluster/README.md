## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.78.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pm_k8s_node"></a> [pm\_k8s\_node](#module\_pm\_k8s\_node) | ./modules/pm_k8s_node | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.bootstrap_token_id](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [random_string.bootstrap_token_secret](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of admin users | <pre>list(object({<br/>    name    = string<br/>    gecos   = string<br/>    ssh_key = string<br/>  }))</pre> | n/a | yes |
| <a name="input_apiserver_advertise_address"></a> [apiserver\_advertise\_address](#input\_apiserver\_advertise\_address) | API server advertise address | `string` | n/a | yes |
| <a name="input_apiserver_bind_port"></a> [apiserver\_bind\_port](#input\_apiserver\_bind\_port) | API server bind port | `number` | `6443` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Comment for the Kubernetes cluster | `string` | `""` | no |
| <a name="input_disks_datastore_id"></a> [disks\_datastore\_id](#input\_disks\_datastore\_id) | ID of the datastore where the disks will be stored | `string` | `"local"` | no |
| <a name="input_ha_groups"></a> [ha\_groups](#input\_ha\_groups) | HA groups for the Kubernetes cluster | <pre>map(object({<br/>    comment     = string<br/>    group       = string<br/>    id          = string<br/>    no_failback = optional(bool, false)<br/>    restricted  = optional(bool, false)<br/>    nodes       = map(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_image_list"></a> [image\_list](#input\_image\_list) | List of images to use for the nodes | <pre>map(object({<br/>    id   = string<br/>    size = number<br/>  }))</pre> | n/a | yes |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version | <pre>object({<br/>    major = number<br/>    minor = number<br/>    patch = number<br/>    build = optional(string, "1.1")<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Network bridge to be used | `string` | `"vmbr0"` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | Networking configuration for the Kubernetes cluster | <pre>object({<br/>    plugin = string<br/>    version = object({<br/>      major = number<br/>      minor = number<br/>      patch = number<br/>    })<br/>    pod_cidr = string<br/>  })</pre> | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Map of nodes in the cluster | <pre>map(object({<br/>    ip_address = string<br/>    ip_gateway = string<br/>    node_type  = string<br/>    tainted    = optional(bool, false)<br/>    pve_node   = optional(string)<br/>    cpu_cores  = optional(number, 2)<br/>    memory     = optional(number, 2048)<br/>    disk_size  = optional(number, 20)<br/>    hosts_entries_override = optional(list(object({<br/>      ip_address = string<br/>      hostname   = string<br/>    })), null)<br/>    version_override = optional(object({<br/>      major = number<br/>      minor = number<br/>      patch = number<br/>      build = optional(string, "1.1")<br/>    }), null)<br/>    networking_override = optional(object({<br/>      plugin = string<br/>      version = object({<br/>        major = number<br/>        minor = number<br/>        patch = number<br/>      })<br/>      pod_cidr = string<br/>    }), null)<br/>    image_list_override = optional(map(object({<br/>      id   = string<br/>      size = number<br/>    })), null)<br/>    os_flavor_override  = optional(string, "debian")<br/>    os_version_override = optional(string, "bookworm")<br/>    certificate_key     = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_os_flavor"></a> [os\_flavor](#input\_os\_flavor) | Operating system flavor for the nodes | `string` | `"debian"` | no |
| <a name="input_os_version"></a> [os\_version](#input\_os\_version) | Operating system version for the nodes | `string` | `"bookworm"` | no |
| <a name="input_snippets_datastore_id"></a> [snippets\_datastore\_id](#input\_snippets\_datastore\_id) | ID of the datastore where the snippets will be stored | `string` | `"local"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the Kubernetes cluster | `list(string)` | `[]` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for the Kubernetes cluster | `string` | `"UTC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_token"></a> [bootstrap\_token](#output\_bootstrap\_token) | The bootstrap token for the Kubernetes cluster. |
| <a name="output_hosts"></a> [hosts](#output\_hosts) | The list of hosts in the Kubernetes cluster. |
