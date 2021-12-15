terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/kyle/.aws/credentials"
  profile                 = "default"
  allowed_account_ids = ["595055244566"]
  default_tags {
    tags = {
      Tree = "Bristlecone"
      Water = "MantaRay"
      Earth = "Moose"
      Air = "ShoebillStork"
      ManagedBy = "terraform"
    }
  }
}

resource "aws_s3_bucket" "static_webpage" {
  bucket = var.website_bucket_name
  acl = "public-read"
  policy = templatefile(
    "${path.module}/policies/iam/s3_public_read.json.tpl",
    {bucket_name = var.website_bucket_name}
    )

  website {
    index_document = "index.html"
  }
}