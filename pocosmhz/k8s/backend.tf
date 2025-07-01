terraform {
  cloud {
    organization = "pocosmhz"
    hostname     = "app.terraform.io" # Optional; defaults to app.terraform.io
    workspaces {
      name = "k8s"
    }
  }
}
