// Creates the AWS Cognito User Pool

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.58.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project = "image-repository"
    }
  }
  profile = "default"
  region  = "us-east-2"
}

resource "aws_cognito_user_pool" "image-repository" {
  name = "image-repository"

  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
}

resource "aws_cognito_user_pool_client" "image-repository" {
  name = "image-repository"

  user_pool_id = aws_cognito_user_pool.image-repository.id
}

resource "aws_cognito_user_pool_domain" "image-repository" {
  domain       = "vincents-img-repo" // MUST BE UNIQUE
  user_pool_id = aws_cognito_user_pool.image-repository.id
}

output "cognito_arn" {
  value = aws_cognito_user_pool.image-repository.arn
}