## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [external_external.cluster_data](https://registry.terraform.io/providers/hashicorp/external/2.3.5/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apiserver_advertise_address"></a> [apiserver\_advertise\_address](#input\_apiserver\_advertise\_address) | API server advertise address | `string` | n/a | yes |
| <a name="input_apiserver_bind_port"></a> [apiserver\_bind\_port](#input\_apiserver\_bind\_port) | API server bind port | `number` | `6443` | no |
| <a name="input_external_url"></a> [external\_url](#input\_external\_url) | External URL for the Kubernetes cluster | `string` | `null` | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version | <pre>object({<br/>    major = number<br/>    minor = number<br/>    patch = number<br/>    build = optional(string, "1.1")<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Map of nodes in the cluster | <pre>map(object({<br/>    ip_address = string<br/>    ip_gateway = string<br/>    node_type  = string<br/>    tainted    = optional(bool, false)<br/>    pve_node   = optional(string)<br/>    cpu_cores  = optional(number, 2)<br/>    memory     = optional(number, 2048)<br/>    disk_size  = optional(number, 20)<br/>    hosts_entries_override = optional(list(object({<br/>      ip_address = string<br/>      hostname   = string<br/>    })), null)<br/>    version_override = optional(object({<br/>      major = number<br/>      minor = number<br/>      patch = number<br/>      build = optional(string, "1.1")<br/>    }), null)<br/>    networking_override = optional(object({<br/>      plugin = string<br/>      version = object({<br/>        major = number<br/>        minor = number<br/>        patch = number<br/>      })<br/>      pod_cidr = string<br/>    }), null)<br/>    image_list_override = optional(map(object({<br/>      id   = string<br/>      size = number<br/>    })), null)<br/>    os_flavor_override  = optional(string, "debian")<br/>    os_version_override = optional(string, "bookworm")<br/>    certificate_key     = optional(string, null)<br/>    ssh_access = optional(object({<br/>      fqdn = string<br/>      port = number<br/>    }), null)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_cert"></a> [cluster\_ca\_cert](#output\_cluster\_ca\_cert) | The CA certificate for the Kubernetes cluster. |
| <a name="output_terraform_token"></a> [terraform\_token](#output\_terraform\_token) | The Terraform token for the Kubernetes cluster. |
