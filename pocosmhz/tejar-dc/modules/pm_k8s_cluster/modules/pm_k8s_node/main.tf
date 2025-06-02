data "http" "k8s_gpg_key" {
  url = "https://pkgs.k8s.io/core:/stable:/v${var.k8s_version.major}.${var.k8s_version.minor}/deb/Release.key"
}

data "http" "docker_gpg_key" {
  url = "https://download.docker.com/linux/${var.os_flavor}/gpg"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.pve_node
  source_raw {
    data      = <<-EOF
    #cloud-config
    local-hostname: ${var.hostname}
    EOF
    file_name = "${var.hostname}-meta-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.pve_node
  source_raw {
    data = templatefile("${path.module}/templates/user-data-cloud-config.tftpl", {
      need_gnupg                  = true
      timezone                    = var.timezone
      root_ssh_key                = tls_private_key.pk.public_key_openssh
      admin_users                 = var.admin_users
      k8s_version                 = var.k8s_version
      networking                  = var.networking
      os_flavor                   = var.os_flavor
      os_version                  = var.os_version
      hosts_entries               = var.hosts_entries
      cp_list                     = join(" ", [for he in var.hosts_entries : he.hostname if he.node_type == "cp"])
      k8s_gpg_key                 = data.http.k8s_gpg_key.response_body
      docker_gpg_key              = data.http.docker_gpg_key.response_body
      node_type                   = var.node_type
      bootstrap_token             = var.bootstrap_token
      tainted                     = var.tainted
      apiserver_advertise_address = var.apiserver_advertise_address
      is_initial_node             = (split("/", var.ip_address)[0] == var.apiserver_advertise_address)
      apiserver_bind_port         = var.apiserver_bind_port
      pod_network_cidr            = var.networking.pod_cidr
      certificate_key             = (var.certificate_key != null ? var.certificate_key : "")
    })
    file_name = "${var.hostname}-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name            = var.hostname
  node_name       = var.pve_node
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
