# Networking components
# 1. kube-vip
# 2. Nginx Ingress Controller
# 3. External DNS
# 4. cert-manager

resource "helm_release" "kube_vip" {
  name       = "kube-vip"
  repository = "https://kube-vip.github.io/helm-charts"
  chart      = "kube-vip"
  version    = "0.6.6"
  create_namespace = true
  namespace  = "kube-vip-system"
  values = [
    templatefile("${path.module}/source/helm/kube-vip/kube-vip-values.tpl.yml", {
      kube_vip = var.k8s_clusters["onprem01"].kube_vip
    })
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.13.0" 
  values = [
    templatefile("${path.module}/source/helm/nginx/nginx-ingress-values.tpl.yml", {
      nginx_conf = var.k8s_clusters["onprem01"].nginx
    })
  ]
}

# To test the Nginx Ingress Controller, you can expose it as a LoadBalancer service:
# kubectl expose deployment ingress-nginx-controller   \
#  --port=80 --target-port=80     --type=LoadBalancer --name http1 \
#     --load-balancer-ip=192.168.18.210
# And this provides:
