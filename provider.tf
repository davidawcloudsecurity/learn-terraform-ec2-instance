# Provider configuration with required providers and version constraints
provider "aws" {
  region = var.aws_region
}
 
terraform {
  # Specify required provider versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
 
  # Backend configuration for state management
  # Demonstrates remote state management concept
    backend "s3" {}
 
  # Specify minimum Terraform version
  required_version = ">= 1.11.0"
}
