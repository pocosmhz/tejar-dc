# pm_ve_vm

Terraform/OpenTofu module to create a single Proxmox VM with cloud-init snippets and optional HA resource.

For an auto-generated Terraform reference (requirements, providers, resources, inputs, outputs), see [`README_tf.md`](README_tf.md).

## Features

- Creates one `proxmox_virtual_environment_vm` instance.
- Uploads cloud-init `meta-data` and `user-data` snippets to Proxmox.
- Generates a per-VM RSA keypair (`tls_private_key`) and injects the public key into root.
- Supports optional HA registration via `proxmox_virtual_environment_haresource`.
- Supports template-driven user-data with extra custom parameters.

## Provider and Versions

This module requires:

- Terraform/OpenTofu version: `>= 1.1, < 1.11.4`
- `bpg/proxmox` provider version: `0.94.0`
- `hashicorp/tls` provider version: `4.1.0`

## Usage

```hcl
module "pm_linux_host" {
  source = "./modules/pm_ve_vm"

  hostname           = "crunch01"
  node_id            = "pve01"
  image_id           = module.pm_ve_vm_debian13_cloud_image["pve01"].id
  disks_datastore_id = var.proxmox_datastore.disks_datastore.id
  ip_address         = "192.168.10.21/24"
  ip_gateway         = "192.168.10.1"

  admin_users = var.admin_users
  packages    = ["vim", "htop"]
  timezone    = var.proxmox_timezone
  tags        = ["linux", "standalone"]

  # Resolves to:
  # ./modules/pm_ve_vm/templates/debian13-user-data-cloud-config.tftpl
  user_data_template = "debian13"

  # Optional template variables
  parameters = {
    need_gnupg = true
  }
}
```

## Available Built-in Templates

Current templates in `templates/`:

- `debian12-user-data-cloud-config.tftpl`
- `debian13-user-data-cloud-config.tftpl`

`user_data_template` must match the prefix before `-user-data-cloud-config.tftpl`.

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `hostname` | `string` | n/a | yes | Name of the VM. |
| `node_id` | `string` | n/a | yes | Proxmox node name where the VM is created. |
| `image_id` | `string` | n/a | yes | Disk image/template file ID used by the VM disk. |
| `ip_address` | `string` | n/a | yes | VM IPv4 CIDR address (example: `192.168.1.10/24`). |
| `ip_gateway` | `string` | n/a | yes | VM IPv4 gateway. |
| `admin_users` | `list(object({ name=string, gecos=string, ssh_key=string }))` | n/a | yes | Admin users rendered into cloud-init template. |
| `user_data_template` | `string` | n/a | yes | Template short name used as `templates/<name>-user-data-cloud-config.tftpl`. |
| `snippets_datastore_id` | `string` | `"local"` | no | Datastore for cloud-init snippet files. |
| `disks_datastore_id` | `string` | `"local"` | no | Datastore for VM disks. |
| `disk_size` | `number` | `10` | no | VM disk size (GiB). |
| `network_bridge` | `string` | `"vmbr0"` | no | Proxmox bridge for NIC. |
| `cpu_cores` | `number` | `1` | no | Number of CPU cores. |
| `cpu_type` | `string` | `"x86-64-v2-AES"` | no | CPU model/type. |
| `memory` | `number` | `512` | no | VM memory in MiB (`dedicated` and `floating`). |
| `os_type` | `string` | `"l26"` | no | Proxmox operating system type. |
| `timezone` | `string` | `"UTC"` | no | Timezone passed to template. |
| `packages` | `list(string)` | `[]` | no | Extra package names passed to template. |
| `tags` | `list(string)` | `[]` | no | Additional VM tags (module always adds `terraform`). |
| `ha_group` | `string` | `null` | no | HA group name. If set, creates HA resource for VM. |
| `parameters` | `any` | `{}` | no | Extra values merged into template variables. |

## Outputs

| Name | Type | Description |
|---|---|---|
| `id` | `number` | ID of the created VM. |
| `ip` | `string` | IPv4 address without CIDR mask. |
| `ssh_key` | `string` (sensitive) | Generated root private key PEM. |
| `ssh_public_key` | `string` | Generated root public key (OpenSSH format). |

## Template Variables

The module renders the selected user-data template with these built-in values:

- `need_gnupg`
- `timezone`
- `root_ssh_key`
- `admin_users`
- `packages`
- `hostname`
- `ip_address`
- `vm_ssh_key`

Then it merges all keys from `parameters` on top of them:

```hcl
merge(builtin_values, var.parameters)
```

So keys in `parameters` can override built-ins when needed.
