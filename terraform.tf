terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
  }
  required_version = ">= 1.6"
}
