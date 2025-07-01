output "k8s_cluster_data" {
  value = {
    for k, v in module.k8s_clusters : k => {
      name                        = k
      apiserver_advertise_address = v.apiserver_advertise_address
      apiserver_bind_port         = v.apiserver_bind_port
      external_url                = v.external_url
      k8s_version                 = v.k8s_version
      terraform_token             = module.k8s_clusters_get_access[k].terraform_token
      cluster_ca_cert             = module.k8s_clusters_get_access[k].cluster_ca_cert
    }
  }
  description = "Access data about the Kubernetes clusters."
  sensitive   = true
}
