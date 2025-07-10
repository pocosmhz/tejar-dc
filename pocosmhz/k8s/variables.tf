variable "k8s_clusters" {
  description = "Kubernetes clusters configuration"
  type = map(object({
    nodes = map(object({
      ip_address = string
      ip_gateway = string
    }))
    ceph = object({
      username     = string
      key          = string
      mon_hosts    = list(string)
      cluster_fsid = string
      rbd_pool     = string
    })
    kube_vip = object({
      address   = string
      interface = string
    })
    nginx = optional(object({
      load_balancer_class = optional(string, "")
      load_balancer_ip    = optional(string, "")
    }))
  }))
  default = {
    k8s01 = {
      nodes = {
        k8s01cp01 = {
          ip_address = "192.168.1.5"
          ip_gateway = "192.168.1.1"
        }
        k8s01cp02 = {
          ip_address = "192.168.1.6"
          ip_gateway = "192.168.1.1"
        }
      }
      kube_vip = {
        address   = "192.168.1.100"
        interface = "eth0"
      }
      nginx = {
        load_balancer_class = "kube-vip.io/kube-vip-class"
        load_balancer_ip    = "192.168.1.100"
      }
      ceph = {
        # we omit the client. prefix !
        username = "kubernetes"
        key      = "ABCABCABCABCABCABCABC4dQ=="
        mon_hosts = [
          "192.168.5.1:6789",
          "192.168.5.2:6789"
        ]
        cluster_fsid = "f4444444-c5a3-4599-af36-b8888b64c0f3"
        rbd_pool     = "kubernetes"
      }
    }
  }
}