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

resource "aws_s3_bucket" "deploy_bucket" {
  bucket = var.deploy_bucket_name
  acl = "private"
}

resource "aws_s3_bucket_object" "go_zip_package" {
  bucket = aws_s3_bucket.deploy_bucket.id
  key = var.go_function_package
  source = "../${var.go_function_package}"
  source_hash = filemd5("../${var.go_function_package}")
}

resource "aws_iam_role" "role_for_lambda" {
  name = "role_for_${var.go_function_name}"
  assume_role_policy = templatefile(
    "${path.module}/policies/iam/assume_role_policy.json.tpl",
    {service = "lambda.amazonaws.com"}
    )
}

resource "aws_lambda_function" "go_function" {
  function_name = var.go_function_name
  role = aws_iam_role.role_for_lambda.arn
  s3_bucket = aws_s3_bucket.deploy_bucket.id
  s3_key = aws_s3_bucket_object.go_zip_package.id
  source_code_hash = filebase64sha256("../${var.go_function_package}")

  runtime = "go1.x"
  handler = "main"
  timeout = 15
}