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

resource "aws_s3_bucket" "image-bucket" {
  bucket = "image-repository-storage-s3-bucket"
  acl    = "private"
}

resource "aws_api_gateway_method" "get-image" {
  rest_api_id   = var.api_id
  resource_id   = var.api_root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get-image" {
  rest_api_id             = var.api_id
  resource_id             = var.api_root_resource_id
  http_method             = aws_api_gateway_method.get-image.http_method
  integration_http_method = aws_api_gateway_method.get-image.http_method

  type = "AWS"

  uri         = "arn:aws:apigateway:us-east-2:s3:path/${aws_s3_bucket.image-bucket.bucket}/Avatar.png"
  credentials = aws_iam_role.s3_api_gateway_role.arn
  depends_on = [
    aws_s3_bucket.image-bucket
  ]
}

resource "aws_api_gateway_method_response" "c200" {
  rest_api_id = var.api_id
  resource_id = var.api_root_resource_id
  http_method = aws_api_gateway_method.get-image.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get-image
  ]
  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "c200" {
  rest_api_id = var.api_id
  resource_id = var.api_root_resource_id
  http_method = aws_api_gateway_method.get-image.http_method
  status_code = aws_api_gateway_method_response.c200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
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
          "Resource" : ["*"]
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
