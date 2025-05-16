# Kubernetes clusters
resource "tls_private_key" "debiantest_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore.local_datastore.id
  node_name    = "pve01"

  source_raw {
    data      = <<-EOF
    #cloud-config
    local-hostname: test-debian12
    EOF
    file_name = "meta-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve01"
  # passwd is the hashed version of your password: mkpasswd --method=SHA-512 --rounds=4096

  source_file {
    path = "${path.module}/../../source/cloud-init/user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "debian_vm" {
  name          = "test-debian12"
  node_name     = "pve01"
  scsi_hardware = "virtio-scsi-single"
  started       = true
  description   = "Managed by Terraform"
  tags          = ["terraform", "debian"]
  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = false

  agent {
    enabled = true
  }
  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = 8192
    floating  = 8192 # set equal to dedicated to enable ballooning
  }
  operating_system {
    type = "l26"
  }
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.18.150/24"
        gateway = "192.168.18.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config.id
  }
  keyboard_layout = "es"

  disk {
    datastore_id = "pool1"
    file_id      = module.pm_ve_vm_debian_cloud_image["pve01"].id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = 32
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    model        = "virtio"
  }
  serial_device {}
}
