output "hosts" {
  description = "The list of hosts in the Kubernetes cluster."
  value = [
    for k, v in var.nodes : {
      name           = k
      ip             = split("/", v.ip_address)[0]
      ssh_key        = module.pm_k8s_node[k].root_private_key_openssh
      ssh_public_key = module.pm_k8s_node[k].root_public_key_openssh
      id             = module.pm_k8s_node[k].id
    }
  ]
  sensitive = true
}

output "apiserver_advertise_address" {
  description = "The API server advertise address for the Kubernetes cluster."
  value       = var.apiserver_advertise_address
}

output "apiserver_bind_port" {
  description = "The API server bind port for the Kubernetes cluster."
  value       = var.apiserver_bind_port
}
output "external_url" {
  description = "The external URL for the Kubernetes cluster."
  value       = var.external_url
}
output "k8s_version" {
  description = "The Kubernetes version for the cluster."
  value       = var.k8s_version
}
output "cluster_ca_cert" {
  description = "The CA certificate for the Kubernetes cluster."
  value       = data.external.cluster_data.result.ca_cert
  sensitive   = true
}

output "terraform_token" {
  description = "The Terraform token for the Kubernetes cluster."
  value       = data.external.cluster_data.result.token
  sensitive   = true
}
