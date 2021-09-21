/**
 * Create an S3 Bucket and accompanying paths to access it
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
resource "aws_s3_bucket" "client-hosting-bucket" {
  bucket = "image-repository-client-s3-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket 		= "${aws_s3_bucket.client-hosting-bucket.id}"
  acl			= "public-read"
  key    		= "env.json"
  content_type 	= "application/json"
  content 		= "{hello: ${aws_s3_bucket.client-hosting-bucket.id}}"
  etag   		= "${aws_s3_bucket.client-hosting-bucket.id}"
}


module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "./client/public"
}

resource "aws_s3_bucket_object" "static_files" {
  for_each = module.template_files.files

  bucket 		= "${aws_s3_bucket.client-hosting-bucket.id}"
  acl			= "public-read"
  key          	= each.key
  content_type 	= each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}