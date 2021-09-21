// Creates the S3 Bucket and integration methods to access it
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

/*
 * OPTION Integration & Response
 */
variable "api_id" {
	type = string
}

variable "resource_id" {
	type = string
}

resource "aws_api_gateway_method" "option-image" {
  rest_api_id = var.api_id
  resource_id = var.resource_id

  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "option-image" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.option-image.http_method

  type             = "MOCK"
  content_handling = "CONVERT_TO_TEXT"

  request_parameters = local.cors-integration-request-header
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
        message    = "OK"
      }
    )
  }
}

resource "aws_api_gateway_method_response" "option-image" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.option-image.http_method
  status_code = 200

  response_parameters = local.cors-method-header
}

resource "aws_api_gateway_integration_response" "option-image" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method_response.option-image.http_method
  status_code = 200

  response_parameters = local.cors-integration-header
}


locals {
  allowed_origin = "'*'"

  cors-method-header = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Max-Age"           = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  cors-integration-header = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods"     = "'GET,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"      = local.allowed_origin
    "method.response.header.Access-Control-Max-Age"           = "'7200'"
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }

  cors-integration-request-header = {
    "integration.request.header.Access-Control-Allow-Headers"     = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "integration.request.header.Access-Control-Allow-Methods"     = "'GET,PUT,OPTIONS'"
    "integration.request.header.Access-Control-Allow-Origin"      = local.allowed_origin
    "integration.request.header.Access-Control-Max-Age"           = "'7200'"
    "integration.request.header.Access-Control-Allow-Credentials" = "'true'"
  }
}
