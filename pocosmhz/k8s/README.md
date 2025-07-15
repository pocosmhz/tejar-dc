# k8s
This part of the IaC tree takes care about Kubernetes clusters **and not** their underlying infrastructure, OS or else.

## Provisioning clusters
By adding an element to the `k8s_clusters` var with the required data (see var definition), you're on your way.

You need different providers for different Kubernetes cluster, that is. See the `providers.tf` and `providers.tofu` files, and Terraform / OpenTofu documentation on how to build and use aliases with providers.

A recommended way of creating assets for the cluster is to name Terraform / Tofu files with a prefix consisting in the Kubernetes cluster name. That is nice and easy to maintain.

### Configuration structure
Every cluster element inside `k8s_clusters` var defines a certain amount of required information on mandatory or optional resources inside that cluster.

A brief, non-comprehensive description, would be:
- Node list (needed for certain things)
- Shared storage with Ceph CSI
- Nginx ingress controller
- Kube-VIP load balancer
- cert-manager
- external-dns
- Providers (see below)

## Providers
In the `providers` section of every cluster definition we'll include parameters needed to configure external resources like DNS entries with `external-dns` or things like that. An example of that would be using Google Cloud DNS for that purpose.

You are responsible of mapping the parameters of providers like Google Cloud, AWS or the like, with the files `providers.tf` / `providers.tofu` and creating the required provider aliases.

### Google Cloud provider
To use your gcloud credentials, run `gcloud auth application-default login`.

Make sure the selected credentials have permissions to access every project listed on all GCP projects used by your resources.

See https://cloud.google.com/docs/authentication/external/set-up-adc for more information

## Nginx ingress settings
You can either set `externalTrafficPolicy` to `Local` and preserve source IP addresses or set to `""` and that would mean `Cluster`.

When you use a `LoadBalancer` service for that, together with `kube-vip`, you must take into account that

1. Read https://kube-vip.io/docs/usage/kubernetes-services/#external-traffic-policy-kube-vip-v050
2. `svc_election` must be `true`.

You can use `externalTrafficPolicy` to `Cluster` with any other service besides the ingress controller service and that will be fine.

Also, in order to get access to source IP address you must enable `use_proxy_protocol` setting on Nginx ingress.

And also, use the [unofficial solution](https://hub.docker.com/r/shilazi/kube-vip) suggested [here](https://github.com/kube-vip/kube-vip/issues/1027#issuecomment-2750374646).
