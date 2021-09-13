variable "api_execution_arn" {
  type = string
}

variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
  type = string
}

output "integration" {
  value = aws_api_gateway_integration.get-image
}

output "method" {
  value = aws_api_gateway_method.get-image-method
}

locals {
  cors-method-header = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Max-Age"           = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  cors-integration-header = {
    
    "method.response.header.Access-Control-Allow-Headers"     = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods"     = "'GET'"
    "method.response.header.Access-Control-Allow-Origin"      = "'*'"
    "method.response.header.Access-Control-Max-Age"           = "'7200'"
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }
}
