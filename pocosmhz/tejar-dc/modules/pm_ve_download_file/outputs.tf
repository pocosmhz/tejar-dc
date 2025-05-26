output "id" {
  description = "The ID of the downloaded file."
  value       = proxmox_virtual_environment_download_file.image.id
}
output "size" {
  description = "The size of the downloaded file."
  value       = proxmox_virtual_environment_download_file.image.size
}
