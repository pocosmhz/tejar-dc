## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1, < 1.11.4 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.78.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.78.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.image](https://registry.terraform.io/providers/bpg/proxmox/0.78.0/docs/resources/virtual_environment_download_file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_content_type"></a> [content\_type](#input\_content\_type) | The content type of the file to be downloaded. | `string` | `"iso"` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | The ID of the datastore where the file will be stored. | `string` | `"local"` | no |
| <a name="input_file_name"></a> [file\_name](#input\_file\_name) | The name of the file to be downloaded. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | The name of the Proxmox node where the file will be downloaded. | `string` | n/a | yes |
| <a name="input_overwrite"></a> [overwrite](#input\_overwrite) | Whether to overwrite the file if different from source. | `bool` | `false` | no |
| <a name="input_url"></a> [url](#input\_url) | The URL of the file to be downloaded. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the downloaded file. |
| <a name="output_size"></a> [size](#output\_size) | The size of the downloaded file. |
