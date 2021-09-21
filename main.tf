// Main terraform infrastructure
// This file determines which AWS Resources are provisioned
// and connects them together

// This file creates the API Gateway & initialize all of its child modules

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

resource "aws_api_gateway_rest_api" "image-repository-api" {
  name = "image-repository-api"

  // Make sure API don't compress return value to UTF-8
  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_method_settings" "log_settings" {
  rest_api_id = aws_api_gateway_rest_api.image-repository-api.id
  stage_name  = aws_api_gateway_deployment.production.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_api_gateway_deployment" "production" {
  stage_description = "Deployed at ${timestamp()}"
  // Automatically redeploy deployment on Terraform change
  lifecycle {
    create_before_destroy = true
  }
  // Ensure integration are created before deployment
  depends_on = [
    module.image-storage.dependency
  ]
  rest_api_id = aws_api_gateway_rest_api.image-repository-api.id
  stage_name  = "production"
}

resource "aws_api_gateway_authorizer" "image-repository" {
  name = "image-repository-api-authorizer"
  rest_api_id = aws_api_gateway_rest_api.image-repository-api.id
  type = "COGNITO_USER_POOLS"

  provider_arns = [
    module.cognito-authentication.cognito_arn
  ]
}

// Creates s3 bucket object and its methods
module "image-storage" {
  source = "./image-storage"

  api_execution_arn    = aws_api_gateway_rest_api.image-repository-api.execution_arn
  api_id               = aws_api_gateway_rest_api.image-repository-api.id
  api_root_resource_id = aws_api_gateway_rest_api.image-repository-api.root_resource_id

  authorizer_id = aws_api_gateway_authorizer.image-repository.id
}

module "cognito-authentication" {
  source = "./cognito-authentication"
}