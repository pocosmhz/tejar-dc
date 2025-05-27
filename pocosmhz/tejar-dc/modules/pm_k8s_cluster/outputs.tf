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

output "bootstrap_token" {
  description = "The bootstrap token for the Kubernetes cluster."
  value       = "${random_string.bootstrap_token_id.result}.${random_string.bootstrap_token_secret.result}"
  sensitive   = true
}
