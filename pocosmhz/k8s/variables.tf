variable "k8s_clusters" {
  description = "Kubernetes clusters configuration"
  type = map(object({
    providers = object({
      gcp = optional(object({
        project = string
        region  = string
        zone    = string
      }))
    })
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
      kind                = optional(string, "Deployment", )
      load_balancer_class = optional(string, "")
      load_balancer_ip    = optional(string, "")
    }))
    external_dns = object({
      parent_zone = object({
        dnsname = string
        name    = string
      })
      zone = object({
        dnsname = string
        name    = string
      })
    })
    cert_manager = optional(object({
      acme = object({
        email  = string
        server = string
      })
      ingress_class = optional(string, "nginx")
    }))
    gitea = optional(object({
      ingress_class       = optional(string, "nginx")
      target              = optional(string, "")
      load_balancer_class = optional(string, "kube-vip.io/kube-vip-class")
      load_balancer_ip    = optional(string, "")
      domain              = optional(string, "gitea.k8s.example.com")
      admin_password      = optional(string, "")
      postgresql_ha       = optional(bool, false)
      pg_password         = optional(string, "pg_password")
      pg_resource_preset  = optional(string, "micro")
    }))
  }))
  default = {
    k8s01 = {
      providers = {
        gcp = {
          project = "my-gcp-project"
          region  = "us-central1"
          zone    = "us-central1-a"
        }
      }
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
      kube_vip = {
        address   = "192.168.1.100"
        interface = "eth0"
      }
      nginx = {
        kind                = "Deployment"
        load_balancer_class = "kube-vip.io/kube-vip-class"
        load_balancer_ip    = "192.168.1.100"
      }
      external_dns = {
        parent_zone = {
          dnsname = "example.com"
          name    = "example-com"
        }
        zone = {
          dnsname = "k8s.example.com"
          name    = "k8s-example-com"
        }
      }
      cert_manager = {
        acme = {
          email  = "email@example.com"
          server = "https://acme-v02.api.letsencrypt.org/directory"
        }
        ingress_class = "nginx"
      }
      gitea = {
        ingress_class       = "nginx"
        target              = "external01.example.com"
        load_balancer_class = "kube-vip.io/kube-vip-class"
        load_balancer_ip    = "192.168.1.100"
        domain              = "gitea.example.com"
        admin_password      = "r8sA8CPHD9!bt6d"
        postgresql_ha       = false
        pg_password         = "pg_password"
        pg_resource_preset  = "micro"
      }
    }
  }
}