## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tls_private_key.pk](https://registry.terraform.io/providers/hashicorp/tls/4.2.1/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Name of the host | `string` | n/a | yes |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | IP address of the host | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the host |
| <a name="output_ssh_key"></a> [ssh\_key](#output\_ssh\_key) | SSH private key for root access |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | SSH public key for root access |
