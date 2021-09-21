/**
 * Create an S3 Bucket and accompanying paths to access it
 * 5 Endpoint in total
 *    - /list OPTIONS
 *    - /list GET
 *    - /item/{key} OPTIONS
 *    - /item/{key} GET
 *    - /item/{key} PUT
 *
 * Also create IAM Policy for the Bucket
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

// Create the S3 Bucket
resource "aws_s3_bucket" "image-bucket" {
  bucket = "image-repository-storage-s3-bucket"
  acl    = "private"
}

// Extract key information from request
resource "aws_api_gateway_resource" "single" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = "item"
}

resource "aws_api_gateway_resource" "single-key" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.single.id
  path_part   = "{key}"
}

/*
 * GET-IMAGE Integration & Response
 */
resource "aws_api_gateway_method" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id

  http_method   = "GET"
  // Use Cognito pool authorization
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id

  // Pass the key the path's `key` parameter to integration
  request_parameters = {
    "method.request.path.key" = true
  }
}

resource "aws_api_gateway_integration" "get-image" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.single-key.id
  http_method             = aws_api_gateway_method.get-image.http_method
  integration_http_method = aws_api_gateway_method.get-image.http_method

  type = "AWS"

  // Get the object from the S3 Bucket
  // The `key` is from the path parameter
  // The folder is the user's unique ID from Cognito Authorizer
  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/{folder}/{key}"
  credentials = aws_iam_role.s3_api_gateway_role.arn

  // Get the `folder` and `key` value as well as
  // pass the CORS headers down to the response
  request_parameters = merge ({
    "integration.request.path.folder" = "context.authorizer.claims.sub"
    "integration.request.path.key"    = "method.request.path.key"
  }, local.cors.integration-request-header)
}

resource "aws_api_gateway_integration_response" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method_response.get-image.http_method
  status_code = "200"

  // Pass these header as well as the CORS down to the Method Response
  response_parameters = merge({
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }, local.cors.integration-header)
}


resource "aws_api_gateway_method_response" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method.get-image.http_method
  status_code = "200"

  // Pass these headers to the users
  response_parameters = merge({
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }, local.cors.method-header)

  response_models = {
    "application/json" = "Empty"
  }
}

/**
 *  Create an OPTIONS endpoint so that the browser correctly
 *  recognize CORS and be able to PUT and Authorize
 */
module "image-option" {
  source = "./cors-option"

  resource_id   = aws_api_gateway_resource.list-folder.id
  api_id        = var.api_id
  cors          = local.cors
}

// Repeat the process for the PUT IMAGE endpoint and LIST IMAGE endpoint

/*
 * PUT-IMAGE Integration & Response
 */
resource "aws_api_gateway_method" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id

  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id

  request_parameters = {
    "method.request.path.key"            = true
    "method.request.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration" "put-image" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.single-key.id
  http_method             = aws_api_gateway_method.put-image.http_method
  integration_http_method = aws_api_gateway_method.put-image.http_method

  type = "AWS"

  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/{folder}/{key}"
  credentials = aws_iam_role.s3_api_gateway_role.arn

  request_parameters = merge({
    "integration.request.path.folder"         = "context.authorizer.claims.sub"
    "integration.request.path.key"            = "method.request.path.key"
    "integration.request.header.Content-Type" = "method.request.header.Content-Type"
  }, local.cors.integration-request-header)
}

resource "aws_api_gateway_method_response" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method.put-image.http_method
  status_code = "200"

  response_parameters = local.cors.method-header
}

resource "aws_api_gateway_integration_response" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method_response.put-image.http_method
  status_code = "200"

  response_parameters = local.cors.integration-header
}

module "list-option" {
  source = "./cors-option"

  resource_id   = aws_api_gateway_resource.single-key.id
  api_id        = var.api_id
  cors          = local.cors
}

// Creates the Integration for Getting the folder's content
// Create the method and integration for the API
resource "aws_api_gateway_resource" "list-folder" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = "list"
}

resource "aws_api_gateway_method" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id

  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "list-folder" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.list-folder.id
  http_method             = aws_api_gateway_method.list-folder.http_method
  integration_http_method = aws_api_gateway_method.list-folder.http_method

  type = "AWS"

  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/?prefix={folder}/"
  credentials = aws_iam_role.s3_api_gateway_role.arn

  request_parameters = merge({
    "integration.request.path.folder" = "context.authorizer.claims.sub"
  }, local.cors.integration-request-header)
}

// Define the method response to specify the Content-Type & Content-Length
resource "aws_api_gateway_method_response" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id
  http_method = aws_api_gateway_method.list-folder.http_method
  status_code = "200"

  response_parameters = local.cors.method-header
}

resource "aws_api_gateway_integration_response" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id
  http_method = aws_api_gateway_method_response.list-folder.http_method
  status_code = "200"

  response_parameters = local.cors.integration-header
}

// Creates the IAM policy to access the s3 bucket
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy"
  description = "Policy for allowing all S3 Actions"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "s3:*",
          "Resource" : ["arn:aws:s3:::image-repository-storage-s3-bucket*"]
        }
      ]
  })
}

resource "aws_iam_role" "s3_api_gateway_role" {
  name = "s3-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.s3_api_gateway_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
