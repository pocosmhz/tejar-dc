terraform {
  required_version = ">= 1.1, < 1.11.4"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
}
