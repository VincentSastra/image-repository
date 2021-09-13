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
  profile = "default"
  region  = "us-east-2"
}

// Create the S3 Bucket
resource "aws_s3_bucket" "image-bucket" {
  bucket = "image-repository-storage-s3-bucket"
  acl    = "private"
}

// Extract folder & key information from request
resource "aws_api_gateway_resource" "single" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = "item"
}

resource "aws_api_gateway_resource" "single-folder" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.single.id
  path_part   = "{folder}"
}

resource "aws_api_gateway_resource" "single-key" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.single-folder.id
  path_part   = "{key}"
}

/*
 * GET-IMAGE Integration & Response
 */
resource "aws_api_gateway_method" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id

  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.folder" = true
    "method.request.path.key"    = true
  }
}

resource "aws_api_gateway_integration" "get-image" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.single-key.id
  http_method             = aws_api_gateway_method.get-image.http_method
  integration_http_method = aws_api_gateway_method.get-image.http_method

  type = "AWS"

  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/{folder}/{key}"
  credentials = aws_iam_role.s3_api_gateway_role.arn

  request_parameters = {
    "integration.request.path.folder" = "method.request.path.folder"
    "integration.request.path.key"    = "method.request.path.key"
  }
}

// Define the method response to specify the Content-Type & Content-Length
resource "aws_api_gateway_method_response" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method.get-image.http_method
  status_code = "200"

  response_parameters = merge({
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }, local.cors-method-header)

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "get-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method_response.get-image.http_method
  status_code = "200"

  response_parameters = merge({
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }, local.cors-integration-header)
}

/*
 * PUT-IMAGE Integration & Response
 */
resource "aws_api_gateway_method" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id

  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.folder"         = true
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

  request_parameters = {
    "integration.request.path.folder"         = "method.request.path.folder"
    "integration.request.path.key"            = "method.request.path.key"
    "integration.request.header.Content-Type" = "method.request.header.Content-Type"
  }
}

resource "aws_api_gateway_method_response" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method.put-image.http_method
  status_code = "200"

  response_parameters = local.cors-method-header
}

resource "aws_api_gateway_integration_response" "put-image" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.single-key.id
  http_method = aws_api_gateway_method_response.put-image.http_method
  status_code = "200"

  response_parameters = local.cors-integration-header
}


// Creates the Integration for Getting the folder's content
// Create the method and integration for the API
resource "aws_api_gateway_resource" "list" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = "list"
}

resource "aws_api_gateway_resource" "list-folder" {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.list.id
  path_part   = "{folder}"
}

resource "aws_api_gateway_method" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id

  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.folder" = true
  }
}

resource "aws_api_gateway_integration" "list-folder" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.list-folder.id
  http_method             = aws_api_gateway_method.list-folder.http_method
  integration_http_method = aws_api_gateway_method.list-folder.http_method

  type = "AWS"

  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/?prefix={folder}/"
  credentials = aws_iam_role.s3_api_gateway_role.arn

  request_parameters = {
    "integration.request.path.folder" = "method.request.path.folder"
  }
}

// Define the method response to specify the Content-Type & Content-Length
resource "aws_api_gateway_method_response" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id
  http_method = aws_api_gateway_method.list-folder.http_method
  status_code = "200"

  response_parameters = local.cors-method-header
}

resource "aws_api_gateway_integration_response" "list-folder" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.list-folder.id
  http_method = aws_api_gateway_method_response.list-folder.http_method
  status_code = "200"

  response_parameters = local.cors-integration-header
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
