terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "AXXXXXXXXXXXXXXXXXXX"
  secret_key = "BXXXXXXXXXXXXXXXXXXX"
}

