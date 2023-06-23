locals {
  default_name =  "${var.name_prefix}-modules"
  dynamodb_table_name = var.storage.dynamodb.name !=null ? var.storage.dynamodb.name  :  local.default_name
  bucket_name = var.storage.bucket.name !=null ? var.storage.bucket.name  :  local.default_name
}

resource "aws_dynamodb_table" "modules" {
  name = local.dynamodb_table_name

  hash_key  = "Id"
  range_key = "Version"

  billing_mode   = var.storage.dynamodb.billing_mode
  read_capacity  = var.storage.dynamodb.billing_mode == "PAY_PER_REQUEST" ? null : var.storage.dynamodb.read
  write_capacity = var.storage.dynamodb.billing_mode == "PAY_PER_REQUEST" ? null : var.storage.dynamodb.write

  # Id is the full namespace/name/provider string used to identify a particular module.
  attribute {
    name = "Id"
    type = "S"
  }

  # Version is a normalized semver-style version number, like 1.0.0.
  attribute {
    name = "Version"
    type = "S"
  }

  tags = merge(var.tags, { Name : local.dynamodb_table_name })
}


resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  tags   = merge(var.tags, { Name : local.bucket_name })
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}