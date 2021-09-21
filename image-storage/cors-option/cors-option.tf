/*
 * OPTION Integration & Response
 */
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

variable "api_id" {
	type = string
}

variable "resource_id" {
	type = string
}

variable "cors" {
  type = any
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

  request_parameters = var.cors.integration-request-header
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

  response_parameters = var.cors.method-header
}

resource "aws_api_gateway_integration_response" "option-image" {
  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method_response.option-image.http_method
  status_code = 200

  response_parameters = var.cors.integration-header
}
