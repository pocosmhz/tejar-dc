terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    tls = {
      source  = "opentofu/tls"
      version = "4.2.1"
    }
  }
}
