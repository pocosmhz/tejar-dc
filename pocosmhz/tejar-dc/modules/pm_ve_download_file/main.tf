resource "proxmox_virtual_environment_download_file" "image" {
  content_type = var.content_type
  datastore_id = var.datastore_id
  node_name    = var.node_name
  url          = var.url
  file_name    = var.file_name
  overwrite    = var.overwrite
}
