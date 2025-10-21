provider "aws" {
  region = "us-east-1" # Update to your desired AWS region
}

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}
