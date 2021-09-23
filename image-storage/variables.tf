variable "api_execution_arn" {
  type = string
}

variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
  type = string
}

variable "image-bucket-name" {
  type = string
}

variable "authorizer_id" {
  type = string
}

output "dependency" {
  value = {
    "get-image"  = aws_api_gateway_integration.get-image
    "put-image"  = aws_api_gateway_integration.put-image
    "list-image" = aws_api_gateway_integration.list-folder
  }
}

locals {
  allowed_origin = "'*'"

  cors = {
    method-header = {
      "method.response.header.Access-Control-Allow-Headers"     = true
      "method.response.header.Access-Control-Allow-Methods"     = true
      "method.response.header.Access-Control-Allow-Origin"      = true
      "method.response.header.Access-Control-Max-Age"           = true
      "method.response.header.Access-Control-Allow-Credentials" = true
    }

    integration-header = {
      "method.response.header.Access-Control-Allow-Headers"     = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
      "method.response.header.Access-Control-Allow-Methods"     = "'GET,PUT,OPTIONS'"
      "method.response.header.Access-Control-Allow-Origin"      = local.allowed_origin
      "method.response.header.Access-Control-Max-Age"           = "'7200'"
      "method.response.header.Access-Control-Allow-Credentials" = "'true'"
    }

    integration-request-header = {
      "integration.request.header.Access-Control-Allow-Headers"     = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
      "integration.request.header.Access-Control-Allow-Methods"     = "'GET,PUT,OPTIONS'"
      "integration.request.header.Access-Control-Allow-Origin"      = local.allowed_origin
      "integration.request.header.Access-Control-Max-Age"           = "'7200'"
      "integration.request.header.Access-Control-Allow-Credentials" = "'true'"
    }
  }
}
