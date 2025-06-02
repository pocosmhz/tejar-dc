resource "kubernetes_namespace" "tejar_dc" {
  metadata {
    name = "tejar-dc"
  }
}

resource "kubernetes_namespace" "tejar_dc2" {
  metadata {
    name = "tejar-dc2"
  }
}
