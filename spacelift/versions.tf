terraform {
  required_providers {
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "spacelift" {
  api_key_endpoint = var.api_key_endpoint
  api_key_id       = var.spacelift_key_id
  api_key_secret   = var.spacelift_key_secret
}

provider "aws" {
  region = var.aws_region
}
