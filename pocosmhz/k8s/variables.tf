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
    traefik = optional(object({
      kind                    = optional(string, "Deployment")
      external_traffic_policy = optional(string, "Local")
      service_type            = optional(string, "LoadBalancer")
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
          class   = optional(string, "traefik")
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
      ingress_class = optional(string, "traefik")
    }))
    forgejo = optional(object({
      ingress_class  = optional(string, "traefik")
      target         = optional(string, "")
      domain         = optional(string, "forgejo.k8s.example.com")
      admin_username = optional(string, "forgejo_admin")
      admin_email    = optional(string, "forgejo@example.com")
      storage_class  = optional(string, "csi-rbd-sc")
      storage_size   = optional(string, "10Gi")
    }))
    irc = optional(object({
      irc_domain          = optional(string, "irc.k8s.example.com")
      chat_domain         = optional(string, "chat.k8s.example.com")
      target              = optional(string, "")
      network_name        = optional(string, "ExampleIRC")
      ingress_class       = optional(string, "traefik")
      storage_class       = optional(string, "csi-rbd-sc")
      ergo_storage_size   = optional(string, "10Gi")
      lounge_storage_size = optional(string, "10Gi")
    }))
    elasticsearch = optional(object({
      clusters = map(object({
        version = optional(string, "8.19.22")
        # Omit kibana to deploy Elasticsearch alone. Kibana shares its version.
        kibana = optional(object({
          domain        = string
          target        = optional(string, "")
          ingress_class = optional(string, "traefik")
          replicas      = optional(number, 1)
          resources = optional(object({
            requests = optional(object({
              cpu    = optional(string, "250m")
              memory = optional(string, "1Gi")
            }), {})
            limits = optional(object({
              cpu    = optional(string, "1")
              memory = optional(string, "2Gi")
            }), {})
          }), {})
        }))
        node_sets = list(object({
          name      = string
          replicas  = number
          disk_size = string
          resources = object({
            requests = object({
              cpu    = string
              memory = string
            })
            limits = object({
              cpu    = string
              memory = string
            })
          })
          roles = list(string)
        }))
      }))
    }))
  }))
  default = {
    # Example configuration only: replace credentials, addresses and domains.
    onprem01 = {
      providers = {
        gcp = {
          project = "my-gcp-project"
          region  = "us-central1"
          zone    = "us-central1-a"
        }
      }
      nodes = {
        onprem01cp01 = {
          ip_address = "192.168.1.5"
          ip_gateway = "192.168.1.1"
        }
        onprem01cp02 = {
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
      traefik = {
        kind                    = "Deployment"
        external_traffic_policy = "Cluster"
        service_type            = "LoadBalancer"
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
            class   = "traefik"
            domain  = "grafana.k8s.example.com"
            target  = "external01.example.com"
          }
          password = "example-grafana-password"
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
          server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        }
        ingress_class = "traefik"
      }
      forgejo = {
        ingress_class  = "traefik"
        target         = "external01.example.com"
        domain         = "forgejo.k8s.example.com"
        admin_username = "forgejo_admin"
        admin_email    = "forgejo@example.com"
        storage_class  = "csi-rbd-sc"
        storage_size   = "10Gi"
      }
      irc = {
        irc_domain          = "irc.k8s.example.com"
        chat_domain         = "chat.k8s.example.com"
        target              = "external01.example.com"
        network_name        = "ExampleIRC"
        ingress_class       = "traefik"
        storage_class       = "csi-rbd-sc"
        ergo_storage_size   = "10Gi"
        lounge_storage_size = "10Gi"
      }
      elasticsearch = {
        clusters = {
          es01 = {
            version = "8.19.22"
            kibana = {
              domain        = "kibana.k8s.example.com"
              target        = "external01.example.com"
              ingress_class = "traefik"
              replicas      = 1
              resources = {
                requests = { cpu = "250m", memory = "1Gi" }
                limits   = { cpu = "1", memory = "2Gi" }
              }
            }
            node_sets = [
              {
                name      = "default"
                replicas  = 2
                disk_size = "20Gi"
                resources = {
                  requests = {
                    cpu    = "1"
                    memory = "2Gi"
                  }
                  limits = {
                    cpu    = "1"
                    memory = "2Gi"
                  }
                }
                roles = ["master", "data", "ingest", "ml", "remote_cluster_client", "transform"]
              }
            ]
          }
        }
      }
    }
  }
}
