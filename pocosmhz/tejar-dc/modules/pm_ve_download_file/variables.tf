variable "content_type" {
  description = "The content type of the file to be downloaded."
  type        = string
  default     = "iso"
}
variable "datastore_id" {
  description = "The ID of the datastore where the file will be stored."
  type        = string
  default     = "local"
}

variable "node_name" {
  description = "The name of the Proxmox node where the file will be downloaded."
  type        = string
}
variable "url" {
  description = "The URL of the file to be downloaded."
  type        = string
}
variable "file_name" {
  description = "The name of the file to be downloaded."
  type        = string
}
