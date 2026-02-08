output "id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "ip" {
  description = "IP address of the VM"
  value       = split("/", var.ip_address)[0]
}

output "ssh_key" {
  description = "SSH private key for root access"
  value       = tls_private_key.pk.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "SSH public key for root access"
  value       = tls_private_key.pk.public_key_openssh
}
