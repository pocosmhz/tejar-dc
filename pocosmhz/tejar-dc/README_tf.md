## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, <= 1.9.1 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.106.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.106.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.2.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.2.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_k8s_clusters"></a> [k8s\_clusters](#module\_k8s\_clusters) | ./modules/pm_k8s_cluster | n/a |
| <a name="module_k8s_clusters_get_access"></a> [k8s\_clusters\_get\_access](#module\_k8s\_clusters\_get\_access) | ./modules/pm_k8s_cluster_get_access | n/a |
| <a name="module_onprem_linux_hosts"></a> [onprem\_linux\_hosts](#module\_onprem\_linux\_hosts) | ./modules/onprem_host | n/a |
| <a name="module_pm_jump_host"></a> [pm\_jump\_host](#module\_pm\_jump\_host) | ./modules/pm_ve_vm_sshpiper | n/a |
| <a name="module_pm_linux_hosts"></a> [pm\_linux\_hosts](#module\_pm\_linux\_hosts) | ./modules/pm_ve_vm | n/a |
| <a name="module_pm_ve_vm_debian12_cloud_image"></a> [pm\_ve\_vm\_debian12\_cloud\_image](#module\_pm\_ve\_vm\_debian12\_cloud\_image) | ./modules/pm_ve_download_file | n/a |
| <a name="module_pm_ve_vm_debian13_cloud_image"></a> [pm\_ve\_vm\_debian13\_cloud\_image](#module\_pm\_ve\_vm\_debian13\_cloud\_image) | ./modules/pm_ve_download_file | n/a |
| <a name="module_pm_ve_vm_ubuntu24_cloud_image"></a> [pm\_ve\_vm\_ubuntu24\_cloud\_image](#module\_pm\_ve\_vm\_ubuntu24\_cloud\_image) | ./modules/pm_ve_download_file | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [time_sleep.wait_pm_jump_host_30_seconds](https://registry.terraform.io/providers/opentofu/time/0.13.1/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of admin users | <pre>list(object({<br/>    name    = string<br/>    gecos   = string<br/>    ssh_key = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "gecos": "Admin User",<br/>    "name": "admin",<br/>    "ssh_key": "ssh-rsa AAAABXXXXXXXXXXX admin@randomhost"<br/>  }<br/>]</pre> | no |
| <a name="input_onprem_standalone_hosts"></a> [onprem\_standalone\_hosts](#input\_onprem\_standalone\_hosts) | List of on-premises hosts to allow access to | <pre>map(object({<br/>    ip_address = string<br/>  }))</pre> | <pre>{<br/>  "linux01": {<br/>    "ip_address": "192.168.1.6/24"<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_datastore"></a> [proxmox\_datastore](#input\_proxmox\_datastore) | Proxmox datastore configuration | <pre>map(object({<br/>    id = string<br/>  }))</pre> | <pre>{<br/>  "disks_datastore": {<br/>    "id": "pool1"<br/>  },<br/>  "iso_datastore": {<br/>    "id": "local"<br/>  },<br/>  "local_datastore": {<br/>    "id": "local"<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_endpoint"></a> [proxmox\_endpoint](#input\_proxmox\_endpoint) | Proxmox API endpoint | `string` | `"https://your-proxmox-server:8006/"` | no |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip SSL verification | `bool` | `true` | no |
| <a name="input_proxmox_jump_host"></a> [proxmox\_jump\_host](#input\_proxmox\_jump\_host) | Proxmox jump host configuration | <pre>object({<br/>    node       = string<br/>    hostname   = string<br/>    ip_address = string<br/>    ip_gateway = string<br/>  })</pre> | <pre>{<br/>  "hostname": "jh01",<br/>  "ip_address": "192.168.1.4/24",<br/>  "ip_gateway": "192.168.1.1",<br/>  "node": "pve01"<br/>}</pre> | no |
| <a name="input_proxmox_k8s_clusters"></a> [proxmox\_k8s\_clusters](#input\_proxmox\_k8s\_clusters) | Proxmox Kubernetes clusters | <pre>map(object({<br/>    comment                     = string<br/>    apiserver_advertise_address = string<br/>    apiserver_bind_port         = number<br/>    external_url                = optional(string, null)<br/>    k8s_version = object({<br/>      major = number<br/>      minor = number<br/>      patch = number<br/>      build = optional(string, "1.1")<br/>    })<br/>    networking = object({<br/>      plugin = string<br/>      version = object({<br/>        major = number<br/>        minor = number<br/>        patch = number<br/>      })<br/>      pod_cidr = string<br/>    })<br/>    os_flavor  = optional(string, "debian")<br/>    os_version = optional(string, "bookworm")<br/>    nodes = map(object({<br/>      ip_address = string<br/>      ip_gateway = string<br/>      cpu_cores  = number<br/>      node_type  = string<br/>      tainted    = bool<br/>      pve_node   = string<br/>      memory     = number<br/>      disk_size  = number<br/>      # Optional parameters, per node<br/>      hosts_entries_override = optional(list(object({<br/>        ip_address = string<br/>        hostname   = string<br/>      })), null)<br/>      version_override = optional(object({<br/>        major = number<br/>        minor = number<br/>        patch = number<br/>        build = optional(string, "1.1")<br/>      }))<br/>      networking_override = optional(object({<br/>        plugin = string<br/>        version = object({<br/>          major = number<br/>          minor = number<br/>          patch = number<br/>        })<br/>        pod_cidr = string<br/>      }), null)<br/>      image_list_override = optional(map(object({<br/>        id   = string<br/>        size = number<br/>      })), null)<br/>      os_flavor_override  = optional(string, "debian")<br/>      os_version_override = optional(string, "bookworm")<br/>      certificate_key     = optional(string, "")<br/>      ssh_access = optional(object({<br/>        fqdn = string<br/>        port = number<br/>      }), null)<br/>    }))<br/>    tags     = list(string)<br/>    timezone = optional(string, "UTC")<br/>  }))</pre> | <pre>{<br/>  "k8s01": {<br/>    "apiserver_advertise_address": "192.168.1.5",<br/>    "apiserver_bind_port": 6443,<br/>    "comment": "Kubernetes cluster 01",<br/>    "k8s_version": {<br/>      "build": "1.1",<br/>      "major": 1,<br/>      "minor": 31,<br/>      "patch": 2<br/>    },<br/>    "networking": {<br/>      "plugin": "calico",<br/>      "pod_cidr": "172.20.0.0/16",<br/>      "version": {<br/>        "major": 3,<br/>        "minor": 30,<br/>        "patch": 0<br/>      }<br/>    },<br/>    "nodes": {<br/>      "k8s01cp01": {<br/>        "cpu_cores": 2,<br/>        "disk_size": 20,<br/>        "ip_address": "192.168.1.5/24",<br/>        "ip_gateway": "192.168.1.1",<br/>        "memory": 4096,<br/>        "node_type": "cp",<br/>        "pve_node": "pve01",<br/>        "ssh_access": {<br/>          "fqdn": "your-k8s-cp-hostname.example.com",<br/>          "port": 22<br/>        },<br/>        "tainted": true<br/>      },<br/>      "k8s01w01": {<br/>        "cpu_cores": 2,<br/>        "disk_size": 20,<br/>        "ip_address": "192.168.1.6/24",<br/>        "ip_gateway": "192.168.1.1",<br/>        "memory": 4096,<br/>        "node_type": "worker",<br/>        "pve_node": "pve02",<br/>        "tainted": false<br/>      }<br/>    },<br/>    "tags": [<br/>      "k8s",<br/>      "debian"<br/>    ],<br/>    "timezone": "Europe/Madrid"<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_network"></a> [proxmox\_network](#input\_proxmox\_network) | Proxmox network configuration | <pre>map(object({<br/>    id   = string<br/>    name = string<br/>  }))</pre> | <pre>{<br/>  "bridge": {<br/>    "id": "vmbr0",<br/>    "name": "vmbr0"<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_nodes"></a> [proxmox\_nodes](#input\_proxmox\_nodes) | List of Proxmox nodes | <pre>map(object({<br/>    ssh_address = string<br/>    ssh_port    = number<br/>  }))</pre> | <pre>{<br/>  "pve01": {<br/>    "ssh_address": "pve01.example.org",<br/>    "ssh_port": 22<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_password"></a> [proxmox\_password](#input\_proxmox\_password) | Proxmox API password | `string` | `"your-password"` | no |
| <a name="input_proxmox_ssh_agent"></a> [proxmox\_ssh\_agent](#input\_proxmox\_ssh\_agent) | Use SSH agent for authentication | `bool` | `false` | no |
| <a name="input_proxmox_ssh_username"></a> [proxmox\_ssh\_username](#input\_proxmox\_ssh\_username) | SSH username for Proxmox nodes | `string` | `"root"` | no |
| <a name="input_proxmox_standalone_hosts"></a> [proxmox\_standalone\_hosts](#input\_proxmox\_standalone\_hosts) | List of standalone hosts to create | <pre>map(object({<br/>    node          = string<br/>    ip_address    = string<br/>    ip_gateway    = string<br/>    cpu_cores     = number<br/>    memory        = number<br/>    disk_size     = number<br/>    template_name = string<br/>    image_id      = optional(string, null)<br/>    packages      = optional(list(string), [])<br/>    tags          = optional(list(string), [])<br/>  }))</pre> | <pre>{<br/>  "linux01": {<br/>    "cpu_cores": 2,<br/>    "disk_size": 20,<br/>    "image_id": "local:iso/debian-13-genericcloud-amd64.img",<br/>    "ip_address": "192.168.1.6/24",<br/>    "ip_gateway": "192.168.1.1",<br/>    "memory": 2048,<br/>    "node": "pve02",<br/>    "template_name": "debian12"<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_timezone"></a> [proxmox\_timezone](#input\_proxmox\_timezone) | Proxmox timezone | `string` | `"Europe/Madrid"` | no |
| <a name="input_proxmox_username"></a> [proxmox\_username](#input\_proxmox\_username) | Proxmox API username | `string` | `"root@pam"` | no |
| <a name="input_proxmox_ve_hagroups"></a> [proxmox\_ve\_hagroups](#input\_proxmox\_ve\_hagroups) | Proxmox HA groups | <pre>map(object({<br/>    name    = string<br/>    comment = string<br/>    nodes   = map(number)<br/>  }))</pre> | <pre>{<br/>  "pve01": {<br/>    "comment": "PVE01 HA group",<br/>    "name": "pve01",<br/>    "nodes": {<br/>      "pve01": 3,<br/>      "pve02": 2,<br/>      "pve03": 1<br/>    }<br/>  },<br/>  "pve02": {<br/>    "comment": "PVE02 HA group",<br/>    "name": "pve02",<br/>    "nodes": {<br/>      "pve01": 1,<br/>      "pve02": 3,<br/>      "pve03": 2<br/>    }<br/>  },<br/>  "pve03": {<br/>    "comment": "PVE03 HA group",<br/>    "name": "pve03",<br/>    "nodes": {<br/>      "pve01": 2,<br/>      "pve02": 1,<br/>      "pve03": 3<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_proxmox_vm_default_images"></a> [proxmox\_vm\_default\_images](#input\_proxmox\_vm\_default\_images) | Default images for Proxmox VMs | <pre>map(object({<br/>    url       = string<br/>    file_name = string<br/>  }))</pre> | <pre>{<br/>  "debian12": {<br/>    "file_name": "debian-12-genericcloud-amd64.img",<br/>    "url": "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"<br/>  },<br/>  "debian13": {<br/>    "file_name": "debian-13-genericcloud-amd64.img",<br/>    "url": "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_k8s_cluster_data"></a> [k8s\_cluster\_data](#output\_k8s\_cluster\_data) | Access data about the Kubernetes clusters. |
