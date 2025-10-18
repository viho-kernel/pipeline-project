terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.16.0" #Aws provider version, not terraform version
    }
  }
}

provider "aws" {
  # Configuration options
    region = "us-east-1"
}