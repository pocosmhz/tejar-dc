# Proxmox default values
proxmox_vm_default_images = {
  debian = {
    url       = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    file_name = "debian-12-genericcloud-amd64.img"
  }
}

proxmox_datastore = {
  disks_datastore = {
    id = "pool1"
  }
  iso_datastore = {
    id = "local"
  }
  local_datastore = {
    id = "local"
  }
}

proxmox_network = {
  bridge = {
    id   = "vmbr0"
    name = "vmbr0"
  }
}

proxmox_timezone = "Europe/Madrid"
