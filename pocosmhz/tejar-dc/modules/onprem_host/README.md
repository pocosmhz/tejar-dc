# onprem_host

Terraform/OpenTofu module to create a set of SSH keys for keeping an inventory of accessible on-premises servers.

For an auto-generated Terraform reference (requirements, providers, resources, inputs, outputs), see [`README_tf.md`](README_tf.md).

## Features

- Generates a per-server RSA keypair (`tls_private_key`) and injects the public key into root.

## Provider and Versions

This module requires:

- Terraform/OpenTofu version: `>= 1.1, < 1.11.4`
- `hashicorp/tls` provider version: `4.2.1`

## Usage

```hcl
module "onprem_linux_hosts" {
  source   = "./modules/onprem_host"
  for_each = var.onprem_standalone_hosts

  hostname   = each.key
  ip_address = each.value.ip_address
}
```

## Inputs

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `hostname` | `string` | n/a | yes | Name of the VM. |
| `ip_address` | `string` | n/a | yes | VM IPv4 CIDR address (example: `192.168.1.10/24`). |

## Outputs

| Name | Type | Description |
|---|---|---|
| `ip` | `string` | IPv4 address without CIDR mask. |
| `ssh_key` | `string` (sensitive) | Generated root private key PEM. |
| `ssh_public_key` | `string` | Generated root public key (OpenSSH format). |

## Using the generated keys

Although the keys are generated and kept in the Tofu state, you have to get every public key and distribute it to the destination server yourself.

```shell
$ tofu show -json | jq -r '
  .. | objects
  | select(.address? == "module.onprem_linux_hosts[\"tejar01\"].tls_private_key.pk")
  | .values.public_key_openssh
'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5AqtvqV4EI2anIGhF1k1IzLyUD58EfEELu0pHOacBxS+0RcAqXSkSoJWt7qgLEWP6KmRpeczNlWdv4IPr5j3P+QMHTpV3B6j8+ri8j6G2RBMbc5Dbv6m4A3zppQ93+OMV+kf0YSxXescTv9f2AlFzVmOmlInFIYBpVdIo4J4ns2/gHTfAlnnm8uCB3oxz7nsIp6QTOmBuEwVeyJktXJ03BWYCzxWX+f9OTFjlvlP/fYzw5/2e9zR6XihWWG3nLHAHpoPxUYgxqjn9BUemMiPzNyzyQRld9+XTCPi9YO9pjjMPzG1FTeaja4PHcaWKo6KXVLguzrucuJUUFbOls4GFShAsueh1+XR3tE4bHU1p+gFPE9aPsoMAXa4pOYTpqFI9a0RJioGNkzZi2YH16fDD6DzXwdvpnAlcaZC/StjAWGsTicRWJg2I0b9ECngpU6LKxhR75WU2T0mu6ANiC4PER541oTd1fR7Tg+E4okk5/KhLGKdv7SZlh/5Quu81e/MvwqxkLG2zEw33Oliw0EVKVQR+dMAUlmbmG8QIHIGuQjMv3AwJwnaPMksM9AzIfAPMd8xZh06ljcN88CdDMZhG5X6W2IC/p79uZq7bW5gL0fQ33iM6cYZqabWOvtWRPdpPIiIgxqocfQeACOFp+vb8sjNgfviYeZOwp9bUMbZoNQ==
```
And then add it to the right `authorized_keys` file for `root` user on that host:
```Shell
root@tejar01:~# mkdir -p .ssh
root@tejar01:~# cat >> .ssh/authorized_keys << EOF
> ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5AqtvqV4EI2anIGhF1k1IzLyUD58EfEELu0pHOacBxS+0RcAqXSkSoJWt7qgLEWP6KmRpeczNlWdv4IPr5j3P+QMHTpV3B6j8+ri8j6G2RBMbc5Dbv6m4A3zppQ93+OMV+kf0YSxXescTv9f2AlFzVmOmlInFIYBpVdIo4J4ns2/gHTfAlnnm8uCB3oxz7nsIp6QTOmBuEwVeyJktXJ03BWYCzxWX+f9OTFjlvlP/fYzw5/2e9zR6XihWWG3nLHAHpoPxUYgxqjn9BUemMiPzNyzyQRld9+XTCPi9YO9pjjMPzG1FTeaja4PHcaWKo6KXVLguzrucuJUUFbOls4GFShAsueh1+XR3tE4bHU1p+gFPE9aPsoMAXa4pOYTpqFI9a0RJioGNkzZi2YH16fDD6DzXwdvpnAlcaZC/StjAWGsTicRWJg2I0b9ECngpU6LKxhR75WU2T0mu6ANiC4PER541oTd1fR7Tg+E4okk5/KhLGKdv7SZlh/5Quu81e/MvwqxkLG2zEw33Oliw0EVKVQR+dMAUlmbmG8QIHIGuQjMv3AwJwnaPMksM9AzIfAPMd8xZh06ljcN88CdDMZhG5X6W2IC/p79uZq7bW5gL0fQ33iM6cYZqabWOvtWRPdpPIiIgxqocfQeACOFp+vb8sjNgfviYeZOwp9bUMbZoNQ==
> EOF
root@tejar01:~# chmod 600 .ssh/authorized_keys 
```

