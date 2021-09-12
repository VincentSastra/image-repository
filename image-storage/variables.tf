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
