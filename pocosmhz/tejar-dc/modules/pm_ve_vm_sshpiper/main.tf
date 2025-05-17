resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_id
  source_raw {
    data      = <<-EOF
    #cloud-config
    local-hostname: ${var.hostname}
    EOF
    file_name = "${var.hostname}-meta-data-cloud-config.yaml"
  }
}

# We will include this very host in the list of hosts we allow access to.
resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_id
  source_raw {
    data = templatefile("${path.module}/templates/user-data-cloud-config.tftpl", {
      need_gnupg       = false
      timezone         = var.timezone
      root_ssh_key     = tls_private_key.pk.public_key_openssh
      admin_users      = var.admin_users
      hosts            = concat([
        {
          name    = var.hostname
          ip      = split("/", var.ip_address)[0]
          ssh_key = tls_private_key.pk.private_key_pem
        }],
        var.hosts)
      sshpiper_version = var.sshpiper_version
    })
    file_name = "${var.hostname}-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name            = var.hostname
  node_name       = var.node_id
  scsi_hardware   = "virtio-scsi-single"
  started         = true
  description     = "Managed by Terraform"
  tags            = distinct(concat(["terraform"], var.tags))
  stop_on_destroy = false

  agent {
    enabled = true
  }
  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }
  memory {
    dedicated = var.memory
    floating  = var.memory # set equal to dedicated to enable ballooning
  }
  operating_system {
    type = var.os_type
  }
  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.ip_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config.id
  }
  keyboard_layout = "es"

  disk {
    datastore_id = var.disks_datastore_id
    file_id      = var.image_id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }
  network_device {
    bridge       = var.network_bridge
    disconnected = false
    enabled      = true
    firewall     = true
    model        = "virtio"
  }
  serial_device {}
}

resource "proxmox_virtual_environment_haresource" "hares" {
  resource_id = "vm:${proxmox_virtual_environment_vm.vm.id}"
  state       = "started"
  group       = var.ha_group
  comment     = "Managed by Terraform"
}
