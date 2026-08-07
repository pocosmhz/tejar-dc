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
      kind                    = optional(string, "Deployment")
      external_traffic_policy = optional(string, "Local")
      use_proxy_protocol      = optional(bool, false)
      load_balancer_class     = optional(string, "")
      load_balancer_ip        = optional(string, "")
    }))
    prometheus = object({
      prometheus = object({
        storage_size = string
      })
      grafana = object({
        enabled = bool
        ingress = object({
          enabled = bool
          class   = optional(string, "nginx")
          domain  = optional(string, "grafana.k8s.example.com")
          target  = optional(string, "")
        })
        password = string
        persistence = object({
          enabled      = bool
          storage_size = string
        })
      })
    })
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
    forgejo = optional(object({
      ingress_class  = optional(string, "nginx")
      target         = optional(string, "")
      domain         = optional(string, "forgejo.k8s.example.com")
      admin_username = optional(string, "forgejo_admin")
      admin_email    = optional(string, "forgejo@local.domain")
      storage_class  = optional(string, "csi-rbd-sc")
      storage_size   = optional(string, "10Gi")
    }))
    opensearch = optional(object({
      ca_common_name         = optional(string, "example.int")
      initial_admin_password = string
      tls_secret_name        = optional(string, "opensearch-tls-secret")
      ca_secret_name         = optional(string)
      clusters = map(object({
        version = optional(string, "2.1.0")
        dashboards = optional(object({
          enable   = optional(bool, false)
          version  = optional(string, "2.1.0")
          replicas = optional(number, 1)
          resources = object({
            requests = object({
              cpu    = string
              memory = string
            })
            limits = optional(object({
              cpu    = string
              memory = string
            }))
          })
        }))
        security = object({
          tls = object({
            transport = object({
              generate = bool
              per_node = bool
              nodes_dn = optional(list(string), [])
            })
          })
        })
        node_pools = set(object({
          component = string
          replicas  = number
          disk_size = string
          resources = object({
            requests = object({
              cpu    = string
              memory = string
            })
            limits = optional(object({
              cpu    = string
              memory = string
            }))
          })
          roles = set(string)
        }))
      }))
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
        kind                    = "Deployment"
        external_traffic_policy = "Cluster"
        use_proxy_protocol      = false
        load_balancer_class     = "kube-vip.io/kube-vip-class"
        load_balancer_ip        = "192.168.1.100"
      }
      prometheus = {
        prometheus = {
          storage_size = "50Gi"
        }
        grafana = {
          enabled = true
          ingress = {
            enabled = true
            class   = "nginx"
            domain  = "grafana.k8s.example.com"
            target  = "external01.example.com"
          }
          password = "prom-operator"
          persistence = {
            enabled      = true
            storage_size = "10Gi"
          }
        }
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
      forgejo = {
        ingress_class  = "nginx"
        target         = "external01.example.com"
        domain         = "forgejo.example.com"
        admin_username = "forgejo_admin"
        admin_email    = "forgejo@example.com"
        storage_class  = "csi-rbd-sc"
        storage_size   = "10Gi"
      }
      opensearch = {
        ca_common_name         = "example.int"
        initial_admin_password = "strong-password"
        tls_secret_name        = "opensearch-tls-secret"
        clusters = {
          os01 = {
            version = "3.2.0"
            security = {
              tls = {
                transport = {
                  generate = false
                  per_node = false
                  nodes_dn = [
                    "CN=opensearch.example.int"
                  ]
                }
              }
            }
            dashboards = {
              enable   = true
              version  = "3.2.0"
              replicas = 1
              resources = {
                requests = {
                  cpu    = "500m"
                  memory = "1Gi"
                }
                limits = {
                  cpu    = "1"
                  memory = "2Gi"
                }
              }
            }
            node_pools = [
              {
                component = "master"
                replicas  = 3
                disk_size = "20Gi"
                resources = {
                  requests = {
                    cpu    = "500m"
                    memory = "1Gi"
                  }
                }
                roles = ["master", "data"]
              },
              {
                component = "data"
                replicas  = 2
                disk_size = "50Gi"
                resources = {
                  requests = {
                    cpu    = "500m"
                    memory = "1Gi"
                  }
                }
                roles = ["data"]
              }
            ]
          }
        }
      }
    }
  }
}
