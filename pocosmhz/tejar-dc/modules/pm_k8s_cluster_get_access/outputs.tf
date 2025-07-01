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
