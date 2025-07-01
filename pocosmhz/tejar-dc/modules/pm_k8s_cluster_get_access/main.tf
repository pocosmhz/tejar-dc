# Kubernetes cluster
locals {
  ssh_access = [for k, v in var.nodes : {
    hostname = k
    fqdn     = v.ssh_access.fqdn
    port     = v.ssh_access.port
  } if split("/", v.ip_address)[0] == var.apiserver_advertise_address][0]
}

data "external" "cluster_data" {
  program = ["ssh",
    "-p ${local.ssh_access.port}",
    "-o", "ConnectionAttempts=30",
    "-o", "UpdateHostKeys=no",
    "-o", "StrictHostKeyChecking=no",
    "root.${local.ssh_access.hostname}@${local.ssh_access.fqdn}", <<EOF
  export KUBECONFIG=/etc/kubernetes/admin.conf
  token=$(kubectl create token terraform --duration=87600h 2> /dev/null)
  ca_cert=$(cat /etc/kubernetes/pki/ca.crt 2> /dev/null)
  jq -n --arg ca_cert "$ca_cert" --arg token "$token" '{"token": $token, "ca_cert":$ca_cert}'
  EOF
  ]
}
