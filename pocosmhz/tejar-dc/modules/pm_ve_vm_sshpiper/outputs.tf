output "root_public_key_openssh" {
  description = "The public key in OpenSSH format."
  value       = tls_private_key.pk.public_key_openssh
}

output "root_private_key_openssh" {
  description = "The private key in OpenSSH format."
  value       = tls_private_key.pk.private_key_openssh
  sensitive   = true
}

output "id" {
  description = "The ID of the VM."
  value       = proxmox_virtual_environment_vm.vm.id
}
