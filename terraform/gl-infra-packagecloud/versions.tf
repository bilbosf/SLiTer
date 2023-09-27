terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"

      configuration_aliases = [aws.replication]
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.14"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.83"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.83"
    }
  }
}
