variable "cognito_user_pool_domain" {
  type = string
  // default = "unique_pool_domain"
}

variable "s3-image-bucket-name" {
  type = string
  // default = "unique_bucket_name_for_image_storage"
}

variable "s3-client-hosting-name" {
  type = string
  // default = "unique_bucket_name_for_client_hosting"
}
