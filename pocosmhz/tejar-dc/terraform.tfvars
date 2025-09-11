# Proxmox default values
proxmox_vm_default_images = {
  debian12 = {
    url       = "https://cloud.debian.org/images/cloud/bookworm/20250703-2162/debian-12-genericcloud-amd64-20250703-2162.qcow2"
    file_name = "debian-12-genericcloud-amd64.img"
  }
  debian13 = {
    url       = "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"
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
