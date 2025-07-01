terraform {
  required_version = ">= 1.1, <= 1.9.1"
  required_providers {
    external = {
      source  = "opentofu/external"
      version = "2.3.5"
    }
  }
}

